use NXCL::Test;
use NXCL::DataTest;
use NXCL::01::Reader::Tokenizer;
use JSON::Dumper::Compact 'jdc';

data_test \*DATA, sub ($v) {
  (jdc tokenize $v) =~ s/\n\z//r;
};

done_testing;

__DATA__
$ if [ lst.length() > 1 ] {
>   say 'multiple';
> }
< [
<   [ "word", "if" ], [ "ws", " " ], [ "enter_call", "[" ], [ "ws", " " ],
<   [ "word", "lst" ], [ "symbol", "." ], [ "word", "length" ],
<   [ "enter_list", "(" ], [ "leave_list", ")" ], [ "ws", " " ],
<   [ "symbol", ">" ], [ "ws", " " ], [ "int", "1" ], [ "ws", " " ],
<   [ "leave_call", "]" ], [ "ws", " " ], [ "enter_block", "{" ],
<   [ "ws", "\n  " ], [ "word", "say" ], [ "ws", " " ], [ "string", "'" ],
<   [ "word", "multiple" ], [ "string", "'" ], [ "semicolon", ";" ],
<   [ "ws", "\n" ], [ "leave_block", "}" ],
< ]
