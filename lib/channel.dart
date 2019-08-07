import 'package:mongo_dart/mongo_dart.dart';
import 'package:votera_server/controllers/ElectionController.dart';
import 'package:votera_server/controllers/NewsController.dart';
import 'package:votera_server/controllers/PollController.dart';
import 'package:votera_server/controllers/RepresentativesController.dart';
import 'package:votera_server/database.dart';
import 'votera_server.dart';

Database appDatabase;

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class VoteraServerChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
    
    // Set up mongo database and open it - NEED logging
    final Db db = Db("mongodb://localhost/votera");
    await db.open();

    if (db == null) {
      return;
    }

    // Set the database
    appDatabase = Database(db);

  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();
  
      // Set up routes
      router

      ..route("/news").link(() => NewsController())
      ..route("/polling").link(() => PollController())
      ..route("/election").link(() => ElectionController())
      ..route("/representatives").link(() => RepresentativesController())
      ..route("/example")
      .linkFunction((request) async { 
        return Response.ok({"key": "value"});
      });
      

    return router;
  }
}