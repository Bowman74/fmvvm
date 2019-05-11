part of fmvvm.interfaces;

abstract class NavigationService {
  Future<void> navigate<T extends ViewModel>({Object parameter});

  void navigateBack();

  ViewModel createViewModel<T extends ViewModel>(Object parameter);

  set currentContext(BuildContext context);
}
