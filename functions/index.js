const admin = require("firebase-admin");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");
const functions = require("firebase-functions/v1");

// Init
admin.initializeApp();
const db = admin.firestore();

// Region (promijeni ako ti je drugi)
setGlobalOptions({ region: "europe-west1" });


const IDENTITY_TOOLKIT_API_KEY = defineSecret("IDENTITY_TOOLKIT_API_KEY");

/**
 * Callable: createEmployee
 *
 * request.data:
 *  {
 *    email: string,
 *    name?: string,
 *    surname?: string,
 *    username?: string
 *  }
 *
 * Preconditions:
 *  - Caller must be logged in
 *  - Caller must exist in Firestore users/{callerUid}
 *  - Caller role must be "ORG_OWNER"
 *  - Caller must have orgId
 */
exports.createEmployee = onCall(async (request) => {
  // 1) auth check
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Moraš biti ulogovan.");
  }

  const callerUid = request.auth.uid;

  // 2) input validation
  const { email, name, surname, username } = request.data || {};
  if (!email || typeof email !== "string") {
    throw new HttpsError("invalid-argument", "Email je obavezan.");
  }
  const normalizedEmail = email.trim().toLowerCase();

  // 3) load caller user document to determine org + role
  const callerSnap = await db.collection("users").doc(callerUid).get();
  if (!callerSnap.exists) {
    throw new HttpsError(
      "permission-denied",
      "Caller user ne postoji u Firestore (users/{uid})."
    );
  }

  const callerUser = callerSnap.data();

  if (!callerUser?.isActive) {
    throw new HttpsError("permission-denied", "Nalog nije aktivan.");
  }
  if (callerUser?.role !== "ORG_OWNER") {
    throw new HttpsError("permission-denied", "Samo ORG_OWNER može dodavati zaposlene.");
  }
  const orgId = callerUser?.orgId;
  if (!orgId) {
    throw new HttpsError("failed-precondition", "Admin nema orgId u svom users dokumentu.");
  }

  // 4) Create Firebase Auth user (no password)
  let createdAuthUser;
  try {
    createdAuthUser = await admin.auth().createUser({
      email: normalizedEmail,
      displayName: `${name || ""} ${surname || ""}`.trim(),
      disabled: false,
    });
  } catch (e) {
    if (e?.code === "auth/email-already-exists") {
      throw new HttpsError("already-exists", "Korisnik sa ovim emailom već postoji.");
    }
    throw new HttpsError("internal", `Ne mogu kreirati Auth user-a: ${e.message}`);
  }

  const employeeUid = createdAuthUser.uid;

  // 5) Set custom claims (recommended for rules / multi-tenant)
  try {
    await admin.auth().setCustomUserClaims(employeeUid, {
      role: "ORG_EMPLOYEE",
      orgId: orgId,
    });
  } catch (e) {
    // cleanup if claim fails
    await admin.auth().deleteUser(employeeUid);
    throw new HttpsError("internal", `Ne mogu postaviti custom claims: ${e.message}`);
  }

  // 6) Write Firestore users/{uid}
  const userDoc = {
    email: normalizedEmail,
    isActive: true,
    name: name || "",
    surname: surname || "",
    username: username || "",
    orgId: orgId,
    role: "ORG_EMPLOYEE",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: callerUid,
  };

  try {
    await db.collection("users").doc(employeeUid).set(userDoc, { merge: true });
  } catch (e) {
    // cleanup if firestore write fails
    await admin.auth().deleteUser(employeeUid);
    throw new HttpsError("internal", `Ne mogu upisati user-a u Firestore: ${e.message}`);
  }

  // 7) Generate password reset link
  // let resetLink;
  // try {
  //   // Ako želiš da nakon reseta vodi na tvoj web/dynamic link, možeš dodati actionCodeSettings:
  //   // const actionCodeSettings = { url: "https://tvoj-domain.com/after-reset" };
  //   // resetLink = await admin.auth().generatePasswordResetLink(normalizedEmail, actionCodeSettings);

  //   resetLink = await admin.auth().generatePasswordResetLink(normalizedEmail);
  // } catch (e) {
  //   throw new HttpsError("internal", `Ne mogu generisati reset link: ${e.message}`);
  // }

  return {
    ok: true,
    uid: employeeUid,
    orgId: orgId,
    user: userDoc
  };
});


//Soft Delte Emplyee func

exports.deleteEmployee = onCall(async (request) => {
  // 1) auth check
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Moraš biti ulogovan.");
  }

  const callerUid = request.auth.uid;

  // 2) input validation
  const { employeeUid } = request.data || {};
  if (!employeeUid || typeof employeeUid !== "string") {
    throw new HttpsError("invalid-argument", "employeeUid je obavezan.");
  }

  if (employeeUid === callerUid) {
    throw new HttpsError("failed-precondition", "Ne možeš deaktivirati sam sebe.");
  }

  // 3) load caller user (to determine org + role)
  const callerSnap = await db.collection("users").doc(callerUid).get();
  if (!callerSnap.exists) {
    throw new HttpsError(
      "permission-denied",
      "Caller user ne postoji u Firestore (users/{uid})."
    );
  }

  const callerUser = callerSnap.data();

  if (!callerUser?.isActive) {
    throw new HttpsError("permission-denied", "Nalog nije aktivan.");
  }

  if (callerUser?.role !== "ORG_OWNER") {
    throw new HttpsError(
      "permission-denied",
      "Samo ORG_OWNER može brisati (deaktivirati) zaposlene."
    );
  }

  const orgId = callerUser?.orgId;
  if (!orgId) {
    throw new HttpsError(
      "failed-precondition",
      "Admin nema orgId u svom users dokumentu."
    );
  }

  // 4) load target employee doc and validate org
  const employeeRef = db.collection("users").doc(employeeUid);
  const employeeSnap = await employeeRef.get();

  if (!employeeSnap.exists) {
    throw new HttpsError("not-found", "Korisnik ne postoji.");
  }

  const employee = employeeSnap.data();

  // Multi-tenant zaštita
  if (employee?.orgId !== orgId) {
    throw new HttpsError(
      "permission-denied",
      "Ne možeš deaktivirati korisnika iz druge organizacije."
    );
  }

  // (opciono) samo zaposlene
  // if (employee?.role !== "ORG_EMPLOYEE") {
  //   throw new HttpsError(
  //     "failed-precondition",
  //     "Možeš deaktivirati samo ORG_EMPLOYEE korisnike."
  //   );
  // }

  // 5) disable in Firebase Auth
  try {
    await admin.auth().updateUser(employeeUid, { disabled: true });
  } catch (e) {
    throw new HttpsError(
      "internal",
      `Ne mogu disable-ovati Auth korisnika: ${e.message}`
    );
  }

  // 6) update Firestore isActive=false
  try {
    await employeeRef.set(
      {
        isActive: false,
        deletedAt: admin.firestore.FieldValue.serverTimestamp(),
        deletedBy: callerUid,
      },
      { merge: true }
    );
  } catch (e) {
    // Auth je već disabled; možeš odlučiti da li želiš rollback (nije preporučeno)
    throw new HttpsError(
      "internal",
      `Auth disabled, ali ne mogu upisati u Firestore: ${e.message}`
    );
  }

  return {
    ok: true,
    employeeUid,
    orgId,
  };
});


exports.sendResetPasswordOnAuthCreate = functions
  .region("europe-west1")
  .runWith({ secrets: [IDENTITY_TOOLKIT_API_KEY] })
  .auth.user()
  .onCreate(async (user) => {
    try {
      if (!user?.email) return null;

      const email = user.email.trim().toLowerCase();
      const apiKey = IDENTITY_TOOLKIT_API_KEY.value();

      const url = `https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${apiKey}`;

      const resp = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          requestType: "PASSWORD_RESET",
          email,
        }),
      });

      if (!resp.ok) {
        const txt = await resp.text();
        console.error(`sendOobCode failed: ${resp.status} ${txt}`);
      } else {
        console.log(`Reset password email sent to: ${email}`);
      }

      return null;
    } catch (e) {
      console.error("Reset password email error:", e);
      return null;
    }
  });