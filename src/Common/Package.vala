
using TeeJee.FileSystem;
using TeeJee.ProcessHelper;
using l.misc;

public class Package : GLib.Object {
	public string pname = "";
	public string version = "";
	public string arch = "";
	public bool is_installed = false;
	public static Gee.ArrayList<Package> dpkg_list = new Gee.ArrayList<Package>();

	public static void initialize() {
		new Package();
	}

	public Package(string s="") {
		vprint("Package("+s+")",4);
		pname = s;
	}

	// get installed packages from dpkg
	public static void mk_dpkg_list() {
		vprint("mk_dpkg_list()",2);
		dpkg_list.clear();
		string std_out, std_err;
		exec_sync("dpkg-query -f '${Package}|${Version}|${Architecture}|${db:Status-Abbrev}\n' -W 'linux-image-*' 'linux-modules-*' 'linux-headers-*'", out std_out, out std_err);
		if (std_out!=null) foreach (string line in std_out.split("\n")) {
			string[] arr = line.split("|");
			if (arr.length != 4) continue;
			if (arr[3].substring(1,1) != "i" ) continue;

			string name = arr[0].strip();
			string vers = arr[1].strip();
			string arch = arr[2].strip();

			if (arch != LinuxKernel.NATIVE_ARCH && arch != "all" && arch != "any") continue;

			var p = new Package(name);
			p.version = vers;
			p.arch = arch;
			dpkg_list.add(p);
			vprint("dpkg_list.add("+p.pname+")  version:"+p.version+"  arch:"+p.arch,2);
		}
		if (dpkg_list.size<1) vprint("!!! Error running dpkg-query: \n"+std_err,1,stderr);
	}
}
