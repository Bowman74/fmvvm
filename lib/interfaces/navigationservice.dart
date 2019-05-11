part of fmvvm_interfaces;

abstract class NavigationService {
  Future<void> navigate<T extends ViewModel>({Object parameter});

  void navigateBack();

  set currentContext(BuildContext context);
}