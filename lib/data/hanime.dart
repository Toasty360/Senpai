class Hentai {
  final int id;
  final String name;
  final List titles;
  final String slug;
  final String description;
  final int views;
  final int interests;
  final String image;
  final String cover;
  final bool is_censored;
  final List tags;

  Hentai(
      this.id,
      this.name,
      this.titles,
      this.slug,
      this.description,
      this.views,
      this.interests,
      this.image,
      this.cover,
      this.is_censored,
      this.tags);
  static Hentai fromjson(json) {
    return Hentai(
        json['id'],
        json['name'],
        json['titles'],
        json['slug'],
        json['description'],
        json['views'],
        json['interests'],
        json['poster_url'] ?? " ",
        json['cover'] ?? " ",
        json['is_censored'],
        json['tags']);
  }
}

class Hservers {
  final String quality;
  final String url;

  Hservers(this.quality, this.url);

  static List<Hservers> fromjson(json) {
    List<Hservers> data = [];
    for (Map e in json["videos_manifest"]["servers"][0]["streams"]) {
      if (e["url"] != "") {
        data.add(Hservers(e["height"], e["url"]));
      }
    }
    return data;
  }
}
