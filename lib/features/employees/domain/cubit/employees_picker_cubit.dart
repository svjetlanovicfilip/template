import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'employees_picker_state.dart';

class EmployeesPickerCubit extends Cubit<Map<String, bool>> {
  EmployeesPickerCubit() : super({});

  void pickEmployee({required String employeeId, required bool isPicked}) {
    emit({...state, employeeId: isPicked});
  }

  void unpickEmployee({required String employeeId}) {
    emit({...state, employeeId: false});
  }

  void clear() {
    emit({});
  }
}
