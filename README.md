## MixingLoomProfiler ##

need submodule : https://github.com/MixingLoom/mixingloom-core.git

just execute :
	git submodule update

to test : add (or replace) this line:
	PreloadSWF=<path-to-mixingloom-reloader>?xmlPath=<path-to-xml>
	
where <path-to-mixingloom-reloader> is the path to the mixingloom-profiler swf

It need to be added to the list of trusted places : [edit config]()

<path-to-xml> is the path to the injection specification xml. it can be relative to the swf you want to profile.