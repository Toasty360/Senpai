class settings {
  static bool enableHentai = false;
  static toggleHentai() => enableHentai = !enableHentai;
  static String qualityChoice = "default";
  static String qualityStatus = qualityChoice == "default" ? "High" : "Low";
}

class currentDownloads {
  static Map<String, bool> downloads = {};
}
