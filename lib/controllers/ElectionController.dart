import 'dart:convert';
import 'package:votera_server/votera_server.dart';
import 'package:http/http.dart' as http;

class ElectionController extends ResourceController {
  
 @Operation.get()
  Future<Response> getElectionDetails(@Bind.query('latitude') String latitude, @Bind.query('longitude') String longitude) async {
    var candidates = await getCandidates(latitude, longitude);
    var electionDate = await getElectionDate();
    return Response.ok({'candidates': candidates, 'electionDate': electionDate});
  }
  
  Future getCandidates(String latitude, String longitude) async {
    final String url = 'https://represent.opennorth.ca/candidates/?point=$latitude,$longitude';
    var request = await http.get(url);
    var data = jsonDecode(request.body);
    print(data);
    var candidates = data['objects'];
    print(candidates);
    List processedCandidates = [];
    for(var candidate in candidates) {

      if (candidate['election_name'] != 'House of Commons') {
        continue;
      }

      Map candidateData = {'':''};

      // Get basic attributes
      candidateData['name'] = candidate['name'];
      candidateData['email'] = candidate['email'];
      candidateData['website'] = candidate['url'];
      candidateData['imageURL'] = candidate['photo_url'];
      candidateData['district'] = candidate['district_name'];
      candidateData['party'] = candidate['party_name'];
      var twitter = candidate['extra']['twitter'];
      candidateData['twitter'] = twitter;
      candidateData['facebook'] = candidate['extra']['facebook'];
      
      processedCandidates.add(candidateData);
    }
  
    return processedCandidates;
  } 

  Future getElectionDate() async {
    var electionDateURL = 'http://yashmulki.me/votera/election-info.json';
    var request = await http.get(electionDateURL);
    var body = jsonDecode(request.body);
    var electionDate = body['date'];
    return electionDate;
  }

}