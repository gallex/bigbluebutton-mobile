package org.bigbluebutton.mobile.services
{	
	import flash.net.NetConnection;
	
	import org.bigbluebutton.mobile.model.Conference;
	import org.bigbluebutton.mobile.model.ConferenceParameters;
	import org.bigbluebutton.mobile.model.User;

	public class UserService
	{
		private var joinService:JoinService;
		private var _conference:Conference;
		private var _userSOService:UserSOService;
		private var _conferenceParameters:ConferenceParameters;
		
		private var applicationURI:String;
		private var hostURI:String;
		
		private var connection:NetConnection;
		private var userId:Number;
				
		public function UserService()
		{
		}
		
		public function startService(applicationURI:String, hostURI:String):void{
			this.applicationURI = applicationURI;
			hostURI = hostURI;
			
			joinService = new JoinService();
			joinService.addJoinResultListener(joinListener);
			joinService.load(hostURI);
		}
		
		private function joinListener(success:Boolean, result:Object):void{
			if (success) {
				_conference = new Conference();
				_conference.me.name = result.username;
				_conference.me.role = result.role;
				_conference.me.room = result.room;
				_conference.me.authToken = result.authToken;
				
				_conferenceParameters = new ConferenceParameters();
				_conferenceParameters.conference = result.conference;
				_conferenceParameters.username = _conference.me.name;
				_conferenceParameters.role = _conference.me.role;
				_conferenceParameters.room = _conference.me.room;
				_conferenceParameters.authToken = _conference.me.authToken;
				_conferenceParameters.mode = result.mode;
				_conferenceParameters.webvoiceconf = result.webvoiceconf;
				_conferenceParameters.voicebridge = result.voicebridge;
				_conferenceParameters.conferenceName = result.conferenceName;
				_conferenceParameters.welcome = result.welcome;
				_conferenceParameters.meetingID = result.meetingID;
				_conferenceParameters.externUserID = result.externUserID;
				
				connect();
			}
		}
		
		private function connect():void{
			_userSOService = new UserSOService(applicationURI, _conferenceParameters);
		}
		
		public function userLoggedIn(userid:Number, connection:NetConnection):void{
			_conference.me.userid = userid;
			_conferenceParameters.connection = connection;
			_conferenceParameters.userid = userid;
			
			//_userSOService.join(e.userid, _conferenceParameters.room);	
		}
		
		public function stop():void {
			//_userSOService.disconnect();
		}
		
		public function get me():User {
			return _conference.me;
		}
		
		public function isModerator():Boolean {
			if (me.role == "MODERATOR") {
				return true;
			}
			
			return false;
		}
		
		public function get participants():Array {
			return _conference.users;
		}
		
		public function assignPresenter(assignTo:Number):void {
			//_userSOService.assignPresenter(assignTo, me.userid);
		}
		
		public function addStream(userid:Number, stream:String):void {
			//_userSOService.addStream(e.userid, e.stream);
		}
		
		public function removeStream(userid:Number, stream:String):void {			
			//_userSOService.removeStream(e.userid, e.stream);
		}
		
		public function raiseHand():void {
			var userid:Number = _conference.me.userid;
			//_userSOService.raiseHand(userid, e.raised);
		}
		
		public function lowerHand(userid:Number):void {
			//if (this.isModerator()) _userSOService.raiseHand(e.userid, false);
		}
		
		public function kickUser(userid:Number):void{
			//if (this.isModerator()) _userSOService.kickUser(userid);
		}
	}
}