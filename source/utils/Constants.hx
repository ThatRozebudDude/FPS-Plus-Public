package utils;

class Constants {
	
	public static final VERSION:String = "9.1.0";
	public static final VERSION_TAG:String = #if final "" #else "Non-Release Build" #end;
	
	public static final BUILD_DATE:String = CompileTime.buildDateString();

	public static final GIT_BRANCH:String = GitCommit.getGitBranch();
	public static final GIT_HASH:String = GitCommit.getGitCommitHash();

	public static final MENU_FRAMERATE:Int = 240;
	public static final EDITOR_FRAMERATE:Int = 120;

}