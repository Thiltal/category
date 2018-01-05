import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:category/src/services/auth_service.dart';

@Component(
  selector: 'header',
  template: '''
  
   <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top" id="mainNav">
      <div class="container">
        <span class="navbar-brand js-scroll-trigger">Group classification experimental page</span>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarResponsive">
          <ul class="navbar-nav ml-auto">
            <li *ngIf="authService.user == null" class="nav-item">
              <a class="nav-link js-scroll-trigger" href="javascript:" (click)="login()">Sign in / Log in</a>
            </li>
            <li *ngIf="authService.user != null" class="nav-item">
              <span class="nav-link js-scroll-trigger">Logged: {{authService.user.email}}</span>
            </li>
          </ul>
        </div>
      </div>
    </nav>
  
  ''',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
  ],
)
class HeaderComponent implements OnInit {
  AuthService authService;
  HeaderComponent(this.authService) {

  }

  @override
  ngOnInit() {
    // TODO: implement ngOnInit
  }

  login(){
    authService.login();
  }
}
