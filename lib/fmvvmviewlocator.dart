part of fmvvm;

class FmvvmViewLocator implements ViewLocator {

  @override
  String getViewFromViewModelType<T extends ViewModel>() {
    String typeName = Utilities.typeOf<T>().toString();

    return typeName.replaceAll('ViewModel', 'View');
  }
}