import 'dart:convert';
import 'package:votera_server/votera_server.dart';
import 'package:http/http.dart' as http;

class RepresentativesController extends ResourceController {
  
 @Operation.get()
  Future<Response> getRepresentatives(@Bind.query('latitude') String latitude, @Bind.query('longitude') String longitude) async {
    var representatives = await fetchRepresentatives(latitude, longitude);
    return Response.ok({'representatives': representatives});
  }
  
  Future fetchRepresentatives(String latitude, String longitude) async {
    final String url = 'https://represent.opennorth.ca/representatives/?point=$latitude,$longitude';
    var request = await http.get(url);
    var data = jsonDecode(request.body);
    var representatives = data['objects'];
    List processedRepresentatives = [];
    for(var representative in representatives) {

      Map representativeData = {'':''};

      // Get basic attributes
      representativeData['name'] = representative['name'];
      representativeData['email'] = representative['email'];
      representativeData['website'] = representative['url'];
      representativeData['imageURL'] = representative['photo_url'];
      representativeData['district'] = representative['district_name'];
      representativeData['party'] = representative['party_name'];
      var twitter = representative['extra']['twitter'];
      representativeData['twitter'] = twitter;
      representativeData['facebook'] = representative['extra']['facebook'];
      representativeData['position'] = representative['elected_office'];
      representativeData['offices'] = representative['offices'];

      // Get latest tweets 
      if (twitter != null) {
        var twitterURL = twitter.toString().replaceFirst('https://twitter.com/', '');
        // To do - get twitter api key and get data
      }

      // Get voting record
      if (representativeData['position'] == 'MP') {
        const baseURL = 'http://api.openparliament.ca';
        const ballotsEndpoint = '/votes/ballots/';
        String codedName = representativeData['name'].toString().replaceAll(' ', '-').toLowerCase();
        var votesEndpoint = baseURL + ballotsEndpoint + '?politician=$codedName';
        print(votesEndpoint);
        var request = await http.get(votesEndpoint);
        var body = jsonDecode(request.body);
        var votes = body['objects'];
        var processedVotes = [];
        for (var vote in votes) {
          var decision = vote['ballot'];
          var voteURL = vote['vote_url'].toString();
          var voteDataEndpoint = baseURL + voteURL;
          var voteRequest = await http.get(voteDataEndpoint);
          var voteBody = jsonDecode(voteRequest.body);
          var voteName = voteBody['description']['en'];
          var processedVote = {'title': voteName, 'decision': decision};
          processedVotes.add(processedVote);
        }
        representativeData['voting-record'] = processedVotes;
      }
      
      processedRepresentatives.add(representativeData);
    }
  
    return processedRepresentatives;
  } 

}