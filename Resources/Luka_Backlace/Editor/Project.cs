#if UNITY_EDITOR

// Project.cs is dedicated towards project information and metadata.
namespace Luka.Backlace
{

    // information about this specific project
    public class Project
    {
        public static readonly string project_name = "Backlace";
        public static readonly string project_path = "Luka_Backlace";
        public static readonly string project_license = "/Licenses/Backlace";
        public static Version version = new Version("1.0.0");
        public static readonly Version version_ui = new Version("2.0.0"); // just internally
        public static readonly string project_docs = "https://luka.moe/docs/backlace";
        public static readonly bool has_license = false; // if the project has a license file, or if you wanna show it
        public static readonly bool has_docs = false; // if the project has documentation, or if you wanna show it
    }

}
#endif // UNITY_EDITOR