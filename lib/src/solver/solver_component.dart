import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:category/src/model/model.dart';
import 'package:category/src/services/auth_service.dart';
import 'package:category/src/services/issues_service.dart';

@Component(
  selector: 'solver',
  template: '''
  <button (click)="selectedIssue.add(null)">close</button>
  <button (click)="save()">save solution</button>
  <canvas #canvas></canvas>
  
  ''',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
  ],
)
class SolverComponent implements OnInit {
  IssuesService issuesService;
  CanvasElement canvasElement;
  SolveMap solveMap;

  @ViewChild("canvas")
  ElementRef canvasElementRef;

  @Input("issue")
  Issue issue;

  final selectedIssue = new StreamController<Issue>();
  @Output()
  Stream<Issue> get selected => selectedIssue.stream;

  SolverComponent(this.issuesService) {}

  @override
  void ngOnInit() {
    CanvasElement canvasElement = canvasElementRef.nativeElement;
    solveMap = new SolveMap(issue, canvasElement);
  }

  void save(){
    issuesService.saveSolution(solveMap.getSolution()..issueUid = issue.uid);
  }
}
