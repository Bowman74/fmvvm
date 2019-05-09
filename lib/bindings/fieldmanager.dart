part of fmvvm_bindings;

class FieldManager {

  List<FieldData> _fieldDataList = new List<FieldData>();

  Object getValue(PropertyInfo propertyInfo) {
    FieldData fieldData = _getFieldData(propertyInfo);
    return fieldData.value;
  }

  void setValue(PropertyInfo propertyInfo, Object value) {
    FieldData fieldData = _getFieldData(propertyInfo);
    fieldData.value = value;
  }

  FieldData _getFieldData(PropertyInfo propertyInfo){
    FieldData returnValue;
    if (_fieldDataList.indexWhere((t) => t.id == propertyInfo.id) == -1) {
      returnValue = _registerPropertyInfo(propertyInfo);
    } else {
      returnValue = _fieldDataList.singleWhere((t) => t.id == propertyInfo.id);
    }
    return returnValue;
  }

  FieldData _registerPropertyInfo(PropertyInfo propertyInfo) {
      propertyInfo._setIdentifier(_fieldDataList.length);
      var fieldData = propertyInfo.createFieldData();
      _fieldDataList.add(fieldData);
      return fieldData;
  }
}