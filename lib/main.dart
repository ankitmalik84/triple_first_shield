// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'dart:collection';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Indian Army Banned App Scanner")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              // Set the background color to red
              decoration: BoxDecoration(
                color: Colors.red, // Set background color to red
              ),
              child: Column(
                  // Center the button
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/img1.png', // Replace 'assets/img1.png' with your image path
                      width: 500, // Adjust the width of the image as needed
                      height: 315, // Adjust the height of the image as needed
                    ),
                    FractionallySizedBox(
                      widthFactor:
                          0.46, // Set the width of the button to 70% of the screen width
                      child: Card(
                        color: Colors.white,
                        shadowColor: Colors.black,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: ListTile(
                            title: const Text(
                              "START",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color:
                                    Colors.black, // Change text color to black
                              ),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const InstalledAppsScreen(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Developed by 11 RSR(A)',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(text),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

// Define a new screen widget to display the list of installed banned apps or the messageclass BannedAppsScreen extends StatefulWidget {
class BannedAppsScreen extends StatefulWidget {
  final List<AppInfo> installedBannedApps;

  const BannedAppsScreen({Key? key, required this.installedBannedApps})
      : super(key: key);

  @override
  _BannedAppsScreenState createState() => _BannedAppsScreenState();
}

class _BannedAppsScreenState extends State<BannedAppsScreen> {
  bool _isUninstalling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List of Banned Apps")),
      body: widget.installedBannedApps.isEmpty
          ? const Center(
              child: Text(
                'No banned app available',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: widget.installedBannedApps.length,
              itemBuilder: (context, index) {
                var app = widget.installedBannedApps[index];
                return Card(
                  child: ListTile(
                    title: Text(app.name),
                    subtitle: Text(app.packageName),
                    onTap: () async {
                      setState(() {
                        _isUninstalling = true;
                      });

                      // Show "Please wait" message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Process to Uninstalling app... Please wait.'),
                        ),
                      );
                      var appPackage = app.packageName;
                      // Uninstall the app
                      bool? uninstallIsSuccessful =
                          await InstalledApps.uninstallApp(app.packageName);

                      setState(() {
                        _isUninstalling = false;
                      });

                      // Wait for the uninstallation process to complete
                      await Future.delayed(const Duration(seconds: 2));

                      // Check app installation status
                      bool? appIsInstalled =
                          await InstalledApps.isAppInstalled(appPackage);

                      // Wait for the checking process to complete
                      await Future.delayed(const Duration(seconds: 1));
                      if (uninstallIsSuccessful == true &&
                          appIsInstalled == false) {
                        // Remove the uninstalled app from the list
                        setState(() {
                          widget.installedBannedApps.removeAt(index);
                        });

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('App uninstalled successfully.'),
                          ),
                        );
                      } else {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to uninstall the app.'),
                          ),
                        );
                      }
                    },
                    onLongPress: () =>
                        InstalledApps.openSettings(app.packageName),
                  ),
                );
              },
            ),
    );
  }
}

class InstalledAppsScreen extends StatefulWidget {
  const InstalledAppsScreen({super.key});

  @override
  _InstalledAppsScreenState createState() => _InstalledAppsScreenState();
}

class _InstalledAppsScreenState extends State<InstalledAppsScreen> {
  List<AppInfo> installedBannedApps = [];
  // HashSet<String> bannedAppsHashSet = HashSet();
  bool _scanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Installed Apps")),
      body: FutureBuilder<List<AppInfo>>(
        future: InstalledApps.getInstalledApps(true, true),
        builder:
            (BuildContext buildContext, AsyncSnapshot<List<AppInfo>> snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? snapshot.hasData
                  ? Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              AppInfo app = snapshot.data![index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: Image.memory(app.icon!),
                                  ),
                                  title: Text(app.name),
                                  subtitle: Text(app.getVersionInfo()),
                                  onTap: () =>
                                      InstalledApps.startApp(app.packageName),
                                  onLongPress: () => InstalledApps.openSettings(
                                      app.packageName),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 150, // Set a fixed width
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _scanning = true;
                                    });
                                    await _checkInstalledApps();
                                    setState(() {
                                      _scanning = false;
                                    });

                                    // Navigate to the new screen with the list of banned apps
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BannedAppsScreen(
                                            installedBannedApps:
                                                installedBannedApps),
                                      ),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Colors.red, // Set button color to red
                                    ),
                                  ),
                                  child: _scanning
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        )
                                      : Text(
                                          'Scan Now',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                          "Error occurred while getting installed apps ...."))
              : const Center(child: Text("Getting apps info...."));
        },
      ),
    );
  }

  Future<void> _checkInstalledApps() async {
    // List of banned app names
    List<String> bannedApps = [
      'Tik Tok',
      'Shareit',
      'kwal',
      'shein',
      'baidu map',
      'clash of king',
      'du battery saver',
      'helo',
      'likee',
      'youcam makeup',
      'mi community',
      'cm browser',
      'virus cleaner',
      'apus browser',
      'romwe',
      'club factory',
      'newsdog',
      'beauty plus',
      'we chat',
      'uc browser',
      'qq mail',
      'weibo',
      'xender',
      'qq music',
      'qq news',
      'bigo live',
      'selfie city',
      'mail master',
      'parellel space',
      'mi video call-xiaomi',
      'we sync',
      'es file explorer',
      'viva video-qu video inc',
      'mel tu',
      'aisle',
      'coffee meet',
      'du recorder',
      'du browser',
      'hago play',
      'cam scanner',
      'clone master',
      'wonder cam',
      'photo wonder',
      'qq player',
      'we meet',
      'sweet selfie',
      'baidu translate',
      'v mate',
      'qq international',
      'qq security',
      'qq launcher',
      'u video',
      'v fly status video',
      'mobile legend',
      'du privacy',
      'apus launcher pro',
      'apus launcher',
      'apus security',
      'apus turbo cleaner',
      'apus flash light',
      'cut cut',
      'baidu',
      'baidu express',
      'face u',
      'share save xiaomi',
      'woo',
      'ok cloud',
      'hinge',
      'cam ocr',
      'in note',
      'voov meeting',
      'super clean',
      'we chat reading',
      'govt we chat',
      'small q brush',
      'tecent welyun',
      'pitu',
      'we chat work',
      'cyber hunter',
      'cyber hunter lite',
      'knives out',
      'super mecha champions',
      'life after',
      'dawn of isles',
      'ludo world',
      'chess rush',
      'pubg',
      'pubg lite',
      'rise of kingdom',
      'art of conquest',
      'dank tanks',
      'war path',
      'game of sultans',
      'gallery vault',
      'smart app lock',
      'message lock',
      'hide app',
      'app lock',
      'app lock lite',
      'dual space',
      'zakzak pro',
      'zakzak lite',
      'music-mp3player',
      'music player',
      'hd camera',
      'cleaner phone booster',
      'web browser fst explorer',
      'video player all format',
      'photo gallery hd & editor',
      'photo gallery & album',
      'badoo',
      'azar',
      'hd cam pro',
      'bumble',
      'elite',
      'web browser-fast privacy & light web explorer',
      'web browser secure explorer',
      'tagged',
      'video player all format hd',
      'lamour lover all over the world',
      'amour video chat',
      'couch',
      'mv master status',
      'apus message center',
      'liv meet with strangers',
      'carrom friends',
      'ludo all start',
      'bike racing',
      'ranger of obilivion',
      'z-cam',
      'go sms',
      'u-dictionary',
      'u-like define selfie',
      'tan-tan real date',
      'mico chat',
      'kutty live',
      'malay social dating app',
      'alipay',
      'alipay hk',
      'mobile taobao',
      'youku',
      'road of kings',
      'sina news',
      'netease',
      'penguin fm',
      'murderous persuits',
      'tencent watchlist',
      'learn chinese ai',
      'huya live',
      'little q album',
      'fighting landlords',
      'hi met tu',
      'mobile legends',
      'vpn for tiktok',
      'vpn for tok-tok',
      'pendluin e-sports asst',
      'buy cars',
      'i-pick',
      'beauty camplus',
      'parallel space lite',
      'chief alimghty',
      'marvel super war',
      'afk arean',
      'creative destruction netease',
      'crusaders of light',
      'mafia city',
      'omyogi net ease',
      'ride out heroes',
      'yimeng jlanghu',
      'legend-raising empire',
      'arena of balor 5v5',
      'soul hunter',
      'rules of survival',
      'ali suppliers',
      'alibaba workbench',
      'ali express',
      'alipay cashier',
      'lalamove india',
      'drive with lalamove india',
      'snack video',
      'facebook',
      'camcard-bcr',
      'soul',
      'chinese social',
      'datein asia',
      'we date',
      'free dating app',
      'adore app',
      'truly chinese',
      'truly asian',
      'chinlove',
      'date my age',
      'flirwish',
      'guys only dating-gay',
      'tubit-live streams',
      'wework china',
      'first love',
      'rola-lesbian social network',
      'cashier wallet',
      'mango tv',
      'mg tv',
      'we tv',
      'we tv light',
      'luckey live',
      'taobao live',
      'ding talk',
      'dentity v',
      'soland 2',
      'boxstar',
      'heroes evolved',
      'happy fish',
      'jallipop match',
      'munchkin match',
      'conquista online-II',
      'garena free fire',
      '360 security',
      'equalizer music player-music,mp-3',
      'five equalizer',
      'instagram',
      'equalizer pro',
      'snap chat',
      'daily hunt',
      'volume booster',
      'pratilipy',
      'camcard for sales force-ent',
      'soland-II ashes of time lite',
      'rise of kingdom/lost crusade',
      'apus security pro',
      'parallel space lite-32',
      'viva video editor',
      'nice video baidu',
      'tencent xrivar',
      'onmyojl arena',
      'app lock',
      'dual space like',
      'popxo',
      'vokal',
      'hungama',
      'yelp',
      'songs.pk',
      'conquer online-mmorpg',
      'conquer online-ii',
      'lve weather and radar',
      'notes-clour notepad',
      'mp3 cutter',
      'voice recorder & changer',
      'bar code scanner',
      'lica cam',
      'eve echoes',
      'astracraft',
      'u game booster',
      'extraodinary ones',
      'bad landers',
      'stick fight',
      'twilight pioneers',
      'ute-match with world',
      'small world',
      'cute u pro',
      'fancy u video chat',
      'real u/golive make friends',
      'moon chat',
      'real u lite',
      'wink',
      'fun chat meet people',
      'fancy u pro',
      'beauty camera',
      'we chat',
      'qq',
      'kik',
      'oo voo',
      'nimbuzz helo',
      'q zone',
      'share chat',
      'viber',
      'line',
      'imo',
      'snow',
      'to tok',
      'hike',
      'health of y',
      'likee',
      'samosa',
      'kwali',
      'reddit',
      'friends feed',
      'zapya',
      'private blogs',
      'tumbir',
      'live me',
      'vigo live',
      'zoom',
      'fast films',
      'we mate',
      'up live',
      'vigo video',
      'cam scanner',
      'beauty plus',
      'true caller',
      'tinder',
      'mono live',
      'truly madly',
      'happn',
      'elo',
      'hd cam',
      'china brands',
      'gear best',
      'banggood',
      'minil the box',
      'tiny deal',
      'dh gate',
      'lighting the box',
      'dx',
      'zulu',
      'tb dress',
      'modlity',
      'rosegal',
      'uc news',
      'romwe',
      'eric dress',
      'ali express'
    ];

    // Get the list of installed apps
    List<AppInfo> installedApps =
        await InstalledApps.getInstalledApps(true, true);

    // Convert banned app names to lowercase
    List<String> lowerCaseBannedApps =
        bannedApps.map((appName) => appName.toLowerCase()).toList();

    // Filter installed apps to find banned apps
    installedBannedApps = installedApps
        .where((app) => lowerCaseBannedApps.contains(app.name.toLowerCase()))
        .toList();

    // Print the number of installed banned apps
    print('Number of installed banned apps: ${installedBannedApps.length}');
    // Print details of installed banned apps
    print('Installed banned apps: $installedBannedApps');
  }
}

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Info")),
      body: FutureBuilder<AppInfo>(
        future: InstalledApps.getAppInfo("com.google.android.gm"),
        builder: (BuildContext buildContext, AsyncSnapshot<AppInfo> snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? snapshot.hasData
                  ? Center(
                      child: Column(
                        children: [
                          Image.memory(snapshot.data!.icon!),
                          Text(
                            snapshot.data!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          Text(snapshot.data!.getVersionInfo())
                        ],
                      ),
                    )
                  : const Center(
                      child: Text("Error while getting app info ...."))
              : const Center(child: Text("Getting app info ...."));
        },
      ),
    );
  }
}
