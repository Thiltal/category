import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:category/src/footer/footer_component.dart';
import 'package:category/src/header/header_component.dart';
import 'package:category/src/issues/add_issue_component.dart';
import 'package:category/src/issues/issue_list_component.dart';
import 'package:category/src/model/model.dart';
import 'package:category/src/services/auth_service.dart';
import 'package:category/src/services/issues_service.dart';
import 'package:category/src/solver/solver_component.dart';


@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [
    materialDirectives,
    HeaderComponent,
    FooterComponent,
    AddIssueComponent,
    IssueListComponent,
    SolverComponent,
    COMMON_DIRECTIVES
  ],
  providers: const [
    materialProviders,
    AuthService,
    IssuesService
  ],
)
class AppComponent {
  AuthService authService;
  Issue currentInSolve;

  AppComponent(this.authService);

  void select(Issue issue) {
    this.currentInSolve = issue;
  }

}
