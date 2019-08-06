import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:votera_server/votera_server.dart';

class PollController extends Controller {

  @override
  FutureOr<RequestOrResponse> handle(Request request) async {
    var poll = await getLatestPoll();
    if (poll == null) {
     return Response.notFound();
    }

    return Response.ok({'polling': poll});
  }

  Future getLatestPoll() async {
    var data = await http.get('https://yashmulki.me/votera/polling.json');
    var body = jsonDecode(data.body);
    return body;
  }

}