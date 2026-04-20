use std::path::PathBuf;

fn main() {
    println!("cargo:rerun-if-changed=ffi.cpp");
    let manifest_dir = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR").unwrap());
    let files = &[
        "libwebm/mkvmuxer/mkvmuxer.cc",
        "libwebm/mkvmuxer/mkvwriter.cc",
        "libwebm/mkvmuxer/mkvmuxerutil.cc",
        "libwebm/mkvparser/mkvparser.cc",
        "libwebm/mkvparser/mkvreader.cc",
        "ffi.cpp",
    ];
    let mut c = cc::Build::new();
    c.cpp(true);
    c.warnings(false);
    if c.get_compiler().is_like_msvc() {
        c.flag("/std:c++17");
        c.flag("/EHsc");
    } else {
        c.flag("-fno-rtti");
        c.flag("-std=gnu++11");
        c.flag("-fno-exceptions");
    }
    c.include(manifest_dir.join("libwebm"));
    for &f in files.iter() {
        c.file(manifest_dir.join(f));
    }
    c.compile("libwebmadapter.a");
}
