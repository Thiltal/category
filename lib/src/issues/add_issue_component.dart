import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:category/src/model/model.dart';
import 'package:category/src/services/auth_service.dart';
import 'package:category/src/services/issues_service.dart';

@Component(
  selector: 'add-issue',
  template: '''
   <h3>Add new issue</h3>
   Name: <input [(ngModel)]="issue.name"><br>
   Nodes (separated by ,): <textarea [(ngModel)]="nodes"></textarea><br>
   
   <button (click)="add()">create issue</button>
  ''',
  directives: const [
    CORE_DIRECTIVES,
    FORM_DIRECTIVES,
    materialDirectives,
  ],
)
class AddIssueComponent {
  Issue issue = new Issue();
  IssuesService issuesService;
  AuthService authService;
  String nodes = "";

  AddIssueComponent(
    this.issuesService,
    this.authService,
  ) {}

  void add() {
    issue.createdByUid = authService.user.uid;
    issue.nodes = nodes.split(",");
    issuesService.addIssue(issue);
    issue = new Issue();
  }
}
