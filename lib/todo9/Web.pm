package todo9::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use DBI;
use Data::Dumper;
use Encode 'decode';

filter 'set_title' => sub {
    my $app = shift;
    sub {
        my ( $self, $c ) = @_;
        $c->stash->{site_name} = __PACKAGE__;
        $app->($self,$c);
    }
};

get '/' => sub {
    my ( $self, $c ) = @_;

#MySQlとの接続
my $user = 'root';
my $passwd = '1108';
my $dbh = DBI->connect('DBI:mysql:ATMARKIT:localhost', $user, $passwd);

#sql文（閲覧）
my $sth = $dbh->prepare("SELECT * FROM todo");
my $sth5 = $dbh->prepare("SELECT * FROM master_content");
#my $sth6 = $dbh->prepare("SELECT * FROM pare_todo order by content");
my $sth6 = $dbh->prepare("SELECT * FROM sub_content");
my $sth7 = $dbh->prepare("SELECT sub_content FROM pare_todo order by content");
#sql文（実行）
$sth->execute;
$sth5->execute;
$sth6->execute;
$sth7->execute;
#$sth8->execute;

#文字列の抽出
my $rows = $sth->fetchall_arrayref(+{});
my $rows5 = $sth5->fetchall_arrayref(+{});
my $rows6 = $sth6->fetchall_arrayref(+{});
my $rows7 = $sth7->fetchall_arrayref(+{});
#my $rows8 = $sth8->fetchall_arrayref(+{});


#終了処理
$sth->finish;
$sth5->finish;
$sth6->finish;
$sth7->finish;
#$sth8->finish;
$dbh->disconnect;

#文字列の代入
$c->render('index.tx', {
rows => $rows,
rows5 => $rows5,
rows6 => $rows6,
rows7 => $rows7,
#rows8 => $rows8,  
greeting => "MyToDoList",
    });
	
};

get '/json' => sub {
    my ( $self, $c ) = @_;
    my $result = $c->req->validator([
        'q' => {
            default => 'Hello',
            rule => [
                [['CHOICE',qw/Hello Bye/],'Hello or Bye']
            ],
        }
    ]);
    $c->render_json({ greeting => $result->valid->get('q') });
};

#indexへの受け渡し
post '/create' => sub {
	my ($self, $c) = @_;
	my $result = $c->req->validator([
	'content' => {
		rule => [
		['NOT_NULL', 'empty body'],
		],
	}
]);

	my ($self, $c) = @_;
	my $result2 = $c->req->validator([
	'sub_content' => {
		rule => [
		['NOT_NULL', 'empty body'],
		],
	}
]);

#post '/create2' => sub {
#	my ($self, $c) = @_;
#	my $result2 = $c->req->validator([
#	'content2' => {
#		['NOT_NULL', 'empty body'],
#		],
#	}
#]);



#空欄時の処理
#if($result->has_error or $result2->has_error)  {
#	#return $c->render_json({error=>1, messages=>$result->errors});
#	#return print("登録できません");
#	$c->halt(403);
#}

#MySQlとの接続
my $user2 = 'root';
my $passwd2 = '1108';
my $dbh2 = DBI->connect('DBI:mysql:ATMARKIT:localhost', $user2, $passwd2);
my $dbh9 = DBI->connect('DBI:mysql:ATMARKIT:localhost', $user2, $passwd2);
#my $id2 = $result->valid('id');
my $content2 = $result->valid('content');
my $sub_content2 = $result2->valid('sub_content');
#$content2 ="日本語";
#$sub_content2 ="日本語";
#$content2 = encode('Shift_JIS', $content2);
#sub_content2 = encode('Shift_JIS', $sub_content2);
#$content2 = encode('UTF-8', $content2);
#$sub_content2 = encode('UTF-8', $sub_content2);
#my$sth2 = $dbh2->prepare("INSERT INTO pare_todo (content,sub_content) VALUES('$content2','$sub_content2')");

my$sth9 = $dbh9->prepare("SELECT id FROM master_content WHERE content = '$content2'");
$sth9->execute;
my $id9 = $sth9->fetchall_arrayref(+{});
$sth9->finish;
$dbh9->disconnect;

my$sth2 = $dbh2->prepare("INSERT INTO sub_content (sub_content,master_content_id) VALUES('$sub_content2',$id9.id)");

$sth2 = $dbh2->prepare("set names utf8");
$sth2->execute;
$sth2->finish;
$dbh2->disconnect;

return "入力完了!";
};

post '/delete' => sub {
my ($self, $c) = @_;
my $result = $c->req->validator([
'id' => {
rule => [
['NOT_NULL', 'empty body'],
],
}
]);

if($result->has_error){
return $c->render_json({error=>1, messages=>$result->errors});
}

#MySQlとの接続(消去)
my $user3 = 'root';
my $passwd3 = '1108';
my $dbh3 = DBI->connect('DBI:mysql:ATMARKIT:localhost', $user3, $passwd3);
#消去するidの獲得
my $id3 = $result->valid('id');
#sql文（消去）
my $sth3 = $dbh3->prepare("DELETE FROM pare_todo WHERE id = '$id3'");
#sql文（実行）
$sth3->execute;
$sth3->finish;
$dbh3->disconnect;

return "消去完了";
};

#編集
post '/edit' => sub {
my ($self, $c) = @_;
my $result = $c->req->validator([
'id' => {
rule => [
['NOT_NULL', 'empty body'],
],
},
'sub_content' => {
rule => [
['NOT_NULL', 'empty body'],
],
}
]);

if($result->has_error){
return $c->render_json({error=>1, messages=>$result->errors});
}

#MySQlとの接続
my $user4 = 'root';
my $passwd4 = '1108';
my $dbh4 = DBI->connect('DBI:mysql:ATMARKIT:localhost', $user4, $passwd4);

my $id4 = $result->valid('id');
my $sub_content4 = $result->valid('sub_content');
my $sth4 = $dbh4->prepare("UPDATE pare_todo SET sub_content = '$sub_content4' WHERE id = '$id4'");

$sth4->execute;
$sth4->finish;
$dbh4->disconnect;

if($result->has_error){
return $c->render_json({error=>1, messages=>$result->errors});
}

return "更新完了";
};

1;