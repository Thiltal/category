part of common;
class Xr0templates{
String login; 
String platform; 
String sign_up; 
String state_nav; 
Map toJson(){
Map out = {};
out['login'] = login;
out['platform'] = platform;
out['sign_up'] = sign_up;
out['state_nav'] = state_nav;

return out;
}
void fromJson(Map json){
login = json['login']; 
platform = json['platform']; 
sign_up = json['sign_up']; 
state_nav = json['state_nav']; 
}
}

class GeneratedResources{
Xr0templates templates; 
Map toJson(){
Map out = {};
out['templates'] = templates.toJson();

return out;
}
void fromJson(Map json){
templates = new Xr0templates()..fromJson(json['templates']); 
}
}

