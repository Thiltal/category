import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:category/src/model/model.dart';
import 'package:category/src/services/issues_service.dart';

@Component(
  selector: 'issue-list',
  template: '''
  <h3>Issue list:</h3>
    <div *ngFor="let issue of issuesService.issues" (click)="select(issue)">
      {{issue.name}} : {{issue.uid}} : {{issue.solvedByLoggedUser}}
    </div>
  ''',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
  ],
)
class IssueListComponent {
  IssuesService issuesService;

  final _selectedIssue = new StreamController<Issue>();
  @Output()
  Stream<Issue> get selected => _selectedIssue.stream;

  IssueListComponent(this.issuesService) {

  }

  void select(Issue issue) {
    _selectedIssue.add(issue);
  }
}
