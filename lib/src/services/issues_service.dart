import 'dart:async';
import 'package:angular/core.dart';
import 'package:category/src/model/model.dart';
import 'package:category/src/services/auth_service.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/src/firestore.dart';
import 'package:firebase/src/interop/firestore_interop.dart';

@Injectable()
class IssuesService {
  List<Issue> issues = [];
  CollectionReference<CollectionReferenceJsImpl> issuesCollection;
  CollectionReference<CollectionReferenceJsImpl> solutionsCollection;
  AuthService authService;

  IssuesService(this.authService) {

    solutionsCollection =
        firebase.firestore().collection('solutions');

    issuesCollection =
        firebase.firestore().collection('issues');
    issuesCollection.onSnapshot.listen((QuerySnapshot query) {
      issues.clear();
      query.forEach((DocumentSnapshot issue) {
        issues.add(new Issue()
          ..fromMap(issue.data())
          ..uid = issue.id
          ..solvedByLoggedUser = authService.userData.solvedIssues.contains(issue.id)
        );
      });
    });
  }

  Future<dynamic> addIssue(Issue issue) async {
    DocumentReference created = await issuesCollection.add(issue.toMap());
  }

  void saveSolution(Solution solution) {
    solution.solverUid = authService.userData.uid;
    solutionsCollection.add(solution.toMap());
    authService.userData.solvedIssues.add(solution.issueUid);
    authService.saveUsedData();
  }
}
