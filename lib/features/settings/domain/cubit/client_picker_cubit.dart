import 'package:bloc/bloc.dart';

import '../../data/client.dart';

class ClientPickerCubit extends Cubit<Client?> {
  ClientPickerCubit() : super(null);

  void pickClient({required Client client}) {
    emit(client);
  }

  void unpickClient() {
    emit(null);
  }

  void clear() {
    emit(null);
  }
}
