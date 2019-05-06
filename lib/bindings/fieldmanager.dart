part of fmvvm_bindings;

class FieldManager {

  List<FieldData> _fieldDataList = new List<FieldData>();

  Object getValue(PropertyInfo propertyInfo) {
    FieldData fieldData = _getFieldData(propertyInfo);
    return fieldData.value;
  }

  Object getValueByName(String name) {
    FieldData fieldData = _fieldDataList.singleWhere((t) => t.name == name);
    return fieldData.value;
  }

  void setValue(PropertyInfo propertyInfo, Object value) {
    FieldData fieldData = _getFieldData(propertyInfo);
    fieldData.value = value;
  }

  void setValueByName(String name, Object value) {
    FieldData fieldData = _fieldDataList.singleWhere((t) => t.name == name);
    fieldData.value = value;
  }

  FieldData _getFieldData(PropertyInfo propertyInfo){
    FieldData returnValue;
    if (_fieldDataList.indexWhere((t) => t.id == propertyInfo.id) == -1) {
      returnValue = propertyInfo.createFieldData();
      _fieldDataList.add(returnValue);
    }
    else
    {
      returnValue = _fieldDataList.singleWhere((t) => t.id == propertyInfo.id);
    }
    return returnValue;
  }
}