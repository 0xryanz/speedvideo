// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'SPEEDVIDEO';

  @override
  String get appTagline => '海量电影、剧集，尽情观看。';

  @override
  String get getStarted => '立即开始';

  @override
  String get signIn => '登录';

  @override
  String get signUp => '注册';

  @override
  String get loginRequired => '需要登录';

  @override
  String get guestLibraryTitle => '登录后同步你的片库';

  @override
  String get guestLibraryHint => '片单、观看进度和下载需要登录；浏览和播放无需登录。';

  @override
  String get watchlistNeedsAccount => '收藏影片需要登录。';

  @override
  String get downloadNeedsAccount => '下载影片需要登录。';

  @override
  String get emptyWatchlistHint => '在影片详情页点「加入片单」，收藏的影片会出现在这里。';

  @override
  String get signOut => '退出登录';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get displayName => '昵称';

  @override
  String get welcomeTitle => '随时随地，想看就看。';

  @override
  String get welcomeSubtitle => '打动你的故事，在每一块屏幕上。';

  @override
  String get signInSubtitle => '登录后继续观看。';

  @override
  String get signUpSubtitle => '创建账号，随时取消。';

  @override
  String get noAccount => '第一次使用 SpeedVideo？';

  @override
  String get haveAccount => '已有账号？';

  @override
  String get createAccount => '创建账号';

  @override
  String get continueLabel => '继续';

  @override
  String get invalidEmail => '请输入有效的邮箱地址。';

  @override
  String get passwordMin => '密码至少需要 8 个字符。';

  @override
  String get nameRequired => '请输入昵称。';

  @override
  String get invalidCredentials => '邮箱或密码不正确。';

  @override
  String get emailTaken => '该邮箱已被注册。';

  @override
  String get somethingWentWrong => '出了点问题，请重试。';

  @override
  String get retry => '重试';

  @override
  String get tryAgain => '再试一次';

  @override
  String get whoIsWatching => '谁在观看？';

  @override
  String get manageProfiles => '管理个人资料';

  @override
  String get done => '完成';

  @override
  String get addProfile => '添加资料';

  @override
  String get editProfile => '编辑资料';

  @override
  String get profileName => '资料名称';

  @override
  String get kidsProfile => '儿童资料';

  @override
  String get kidsProfileHint => '仅显示适合儿童观看的内容。';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get deleteProfileTitle => '删除资料？';

  @override
  String deleteProfileMessage(Object name) {
    return '“$name”及其观看记录将被移除。';
  }

  @override
  String get profileLimitReached => '已达到资料数量上限。';

  @override
  String get home => '首页';

  @override
  String get search => '搜索';

  @override
  String get newHot => '新片热门';

  @override
  String get myNetflix => '我的';

  @override
  String get play => '播放';

  @override
  String get resume => '继续播放';

  @override
  String get moreInfo => '更多信息';

  @override
  String get myList => '我的片单';

  @override
  String get addToMyList => '加入我的片单';

  @override
  String get removeFromMyList => '从我的片单移除';

  @override
  String get top10Today => '今日热门 Top 10';

  @override
  String get continueWatching => '继续观看';

  @override
  String continueWatchingFor(String name) {
    return '$name，继续观看';
  }

  @override
  String get newReleases => '新片上线';

  @override
  String get myListTitle => '我的片单';

  @override
  String get trendingNow => '正在流行';

  @override
  String get searchHint => '搜索剧集、电影等';

  @override
  String get searchEmpty => '寻找下一个故事';

  @override
  String get searchEmptyHint => '按片名或类型搜索。';

  @override
  String noResults(String query) {
    return '未找到“$query”';
  }

  @override
  String get genres => '类型';

  @override
  String get season => '季';

  @override
  String seasonNumber(int number) {
    return '第 $number 季';
  }

  @override
  String get episodes => '剧集';

  @override
  String get moreLikeThis => '更多类似内容';

  @override
  String get cast => '主演';

  @override
  String get director => '导演';

  @override
  String matchLabel(int percent) {
    return '$percent% 匹配';
  }

  @override
  String get episode => '单集';

  @override
  String minutes(int count) {
    return '$count 分钟';
  }

  @override
  String get settings => '设置';

  @override
  String get account => '账号';

  @override
  String get language => '语言';

  @override
  String get playback => '播放';

  @override
  String get autoplayNext => '自动播放下一集';

  @override
  String get downloads => '下载';

  @override
  String get downloadsEmpty => '暂无下载';

  @override
  String get downloadsEmptyHint => '下载的内容会出现在这里，可离线观看。';

  @override
  String get help => '帮助';

  @override
  String get about => '关于';

  @override
  String get profile => '个人资料';

  @override
  String get signOutConfirm => '退出 SpeedVideo？';

  @override
  String get offlineBanner => '当前离线，请检查网络连接。';

  @override
  String get playerError => '暂时无法播放该内容。';

  @override
  String get nextEpisode => '下一集';

  @override
  String get tvRemoteHint => 'OK 播放/暂停 · ◀ ▶ 快退/快进 10 秒 · 返回 退出';

  @override
  String get skipIntro => '跳过片头';

  @override
  String get loading => '加载中';

  @override
  String get noInternet => '无网络连接';

  @override
  String get selectProfile => '选择资料以开始观看。';

  @override
  String get manage => '管理';

  @override
  String get viewAll => '查看全部';

  @override
  String get recentlyAdded => '最近添加';

  @override
  String get popular => '热门';

  @override
  String get accountEmail => '邮箱';

  @override
  String get plan => '会员方案';

  @override
  String get memberSince => '注册时间';

  @override
  String get appearance => '外观';

  @override
  String get system => '跟随系统';

  @override
  String get english => 'English';

  @override
  String get chinese => '简体中文';

  @override
  String get aboutBody => '使用 Flutter 与 Go 打造的流媒体体验。';

  @override
  String get apiUnavailable => '无法连接 SpeedVideo，请确认 API 已启动。';

  @override
  String get more => '展开';

  @override
  String get less => '收起';

  @override
  String seasonsCount(int count) {
    return '$count 季';
  }

  @override
  String get aboutApp => '关于 SpeedVideo';

  @override
  String get download => '下载';

  @override
  String get downloading => '下载中';

  @override
  String get downloaded => '已下载';

  @override
  String get downloadFailed => '下载失败。';

  @override
  String get downloadUnavailable => '该内容暂不支持下载。';

  @override
  String get downloadRemoved => '已删除下载。';

  @override
  String downloadStarted(String name) {
    return '正在下载《$name》';
  }

  @override
  String get storedOnDevice => '已保存在本机。';

  @override
  String get notDownloaded => '本机尚未下载该内容。';

  @override
  String get deleteDownloadTitle => '删除下载？';

  @override
  String deleteDownloadMessage(String name) {
    return '将从本机移除《$name》。';
  }

  @override
  String downloadsSize(String size) {
    return '本机共 $size';
  }

  @override
  String get noMatches => '没有符合筛选条件的内容。';

  @override
  String get movieLabel => '电影';

  @override
  String get cancelDownload => '取消下载';

  @override
  String get deleteDownload => '删除下载';

  @override
  String get switchProfile => '切换资料';

  @override
  String get emptyListTitle => '片单还是空的';

  @override
  String get emptyListHint => '添加到“我的片单”的内容会显示在这里。';

  @override
  String get recentSearches => '最近搜索';

  @override
  String get clear => '清除';

  @override
  String get emptyCatalogueTitle => '片库还是空的';

  @override
  String get emptyCatalogueHint => '采集程序入库后，影片会出现在这里。';

  @override
  String get playbackSource => '播放源';

  @override
  String get playbackSourceHint => '选择用哪个片源播放。';

  @override
  String get playbackSourceDefault => '默认片源';

  @override
  String episodesCount(int count) {
    return '$count 集';
  }
}
