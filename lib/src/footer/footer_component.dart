import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';


@Component(
  selector: 'footer',
  template: '''
      <div class="container">
        <p class="m-0 text-center text-white">Copyright &copy; Group Classification 2017</p>
      </div>
  ''',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
  ],
)
class FooterComponent implements OnInit {


  @override
  ngOnInit() {
    // TODO: implement ngOnInit
  }

}
