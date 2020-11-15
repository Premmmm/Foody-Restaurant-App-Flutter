class Details {
  final String name;
  final String price;
  final String url;
  final String type;
  final String ingredients;
  final String rating;
  final String reviewers;
  Details(
      {this.name,
      this.ingredients,
      this.price,
      this.type,
      this.url,
      this.rating,
      this.reviewers});
}

class CategoriesAndDetails {
  final List<Details> details;
  final String category;
  CategoriesAndDetails({this.details, this.category});
}
