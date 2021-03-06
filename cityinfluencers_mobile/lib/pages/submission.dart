import 'package:cityinfluencers_mobile/apis/cityinfluencer_api.dart';
import 'package:cityinfluencers_mobile/models/campaign.dart';
import 'package:cityinfluencers_mobile/models/influencer.dart';
import 'package:cityinfluencers_mobile/models/submission.dart';
import 'package:cityinfluencers_mobile/pages/campaignDetail.dart';
import 'package:cityinfluencers_mobile/services/storage_service.dart';
import 'package:cityinfluencers_mobile/widgets/navigation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SubmissionPage extends StatefulWidget {
  Widget _body = const CircularProgressIndicator();
  SubmissionPage(
      {Key? key,
      required this.influencerId,
      this.username,
      required this.campaignId})
      : super(key: key);
  final int? influencerId;
  final String? username;
  final int campaignId;

  @override
  State<StatefulWidget> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  Influencer? influencer;
  Campaign? campaign;
  Submission? submission;
  Storage storage = Storage();
  //beginstate checks
  @override
  void initState() {
    _getStarted(widget.username, widget.campaignId, widget.influencerId);
    super.initState();
  }

  //opvragen van de Influencer gegevens, campagne gegevens en submission gegevens
  void _getStarted(String? username, int? campaignId, int? influencerId) async {
    await CityInfluencerApi.fetchUser(username!).then((result) {
      setState(() {
        influencer = result;
      });
    });
    await CityInfluencerApi.fetchCampaign(campaignId!).then((result) {
      setState(() {
        campaign = result;
      });
    });
    await CityInfluencerApi.fetchSubmission(influencerId!, campaignId)
        .then((result) {
      setState(() {
        submission = result;
      });
    });
    setState(() => widget._body = realbody());
  }

  //apparte body om null error te vermijden tijdens loading
  Widget realbody() {
    return Scaffold(
      //banner
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          toolbarHeight: MediaQuery.of(context).size.height * 0.1,
          title: Align(
            alignment: Alignment.topRight,
            child: Image.asset("assets/ci-logo.png",
                fit: BoxFit.cover, height: 100),
          ),
        ),
        body: SingleChildScrollView( 
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              //titel
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(campaign!.name,
                      style:
                          const TextStyle(fontSize: 25, color: Colors.black))),
              //afbeelding submission uploaden
              FutureBuilder(
                  future: storage.getFile(submission!.url!),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: FadeInImage(
                            placeholder: const AssetImage(
                                'assets/placeholder-image.png'),
                            image: NetworkImage(snapshot.data!),
                            fit: BoxFit.cover,
                          ));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return Container();
                  }),
              ElevatedButton(
                  onPressed: () async {
                    final results = await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                      type: FileType.custom,
                      allowedExtensions: ['png', 'jpg'],
                    );

                    if (results == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No File selected.')));
                      return null;
                    }

                    final path = results.files.single.path!;
                    final fileName = results.files.single.name;

                    storage
                        .uploadFile(path, fileName)
                        .then((value) => print('done'));

                    submission!.url = fileName;
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      onPrimary: Colors.white),
                  child: const Text('Afbeelding')),
              //multiline input voor de post
              Container(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.10,
                  right: MediaQuery.of(context).size.width * 0.10,
                ),
                child: TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Jouw Post',
                    hintText: submission!.description,
                  ),
                  onChanged: (String string) {
                    submission!.description = string;
                  },
                ),
              ),
              //submit knop
              Container(
                  padding: const EdgeInsets.only(top: 20),
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        onPrimary: Colors.white),
                    onPressed: () {
                      _onSubmit(submission!);
                    },
                    child: const Text('Submit'),
                  ))
            ]))));
  }

  //build
  @override
  Widget build(BuildContext context) {
    return widget._body;
  }

  //POST van de post naar de API
  _onSubmit(Submission submission) async {
    submission.submissionStatus.statusId = 2;
    submission.submissionStatus.name = "Ingezonden";
    await CityInfluencerApi.updateSubmission(submission);
    _navigateToCampaign(influencer!.user.userName, campaign!.id);
  }

  //navigation call naar campagne pagina
  void _navigateToCampaign(String? userName, int campaignId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CampaignDetailPage(username: userName, id: campaignId)),
    );
  }
}
