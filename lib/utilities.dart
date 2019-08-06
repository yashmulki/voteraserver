class Utilities {
  static List encondeToJson(List<dynamic> list){
    List jsonList = List();
    list.map((item)=>
      jsonList.add(item.toJson())
    ).toList();
    return jsonList;
  }
}