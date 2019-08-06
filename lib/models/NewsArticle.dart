class NewsArticle {
  NewsArticle({this.source, this.title, this.description, this.imageURL, this.articleURL});
  NewsArticle.fromMap(Map<String, dynamic> data) {
    source = data['source']['name'] as String;
    title = data['title'] as String;
    description = data['description'] as String;
    imageURL = data['urlToImage'] as String;
    articleURL = data['url'] as String;
  }

  String source;
  String title;
  String description;
  String imageURL;
  String articleURL;

  Map<String, String> toJson() =>
    {
      'source': source,
      'title': title,
      'description': description,
      'imageURL': imageURL,
      'articleURL': articleURL
    };

}