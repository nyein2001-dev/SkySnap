import 'package:flutter_bloc/flutter_bloc.dart';

class ShowBackCubit extends Cubit<bool> {
  ShowBackCubit() : super(false);

  void setPage(bool page) => emit(page);

  bool getPage() => state;
}
