<img class="pull-left" src="img/logo.png" />
{{#logged}}
    <li>
        <a href="javascript:" class="emailNav">{{email}}</a>
    </li><li>
        <a href="javascript:" class="logoutNav">Logout</a>
    </li>
{{/logged}}

{{^logged}}
    <li>
        <a href="javascript:" class="signUpNav">Sign up</a>
    </li><li>
        <a href="javascript:" class="loginNav">Login</a>
    </li>
{{/logged}}

