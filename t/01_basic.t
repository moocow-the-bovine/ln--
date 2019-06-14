#!/usr/bin/perl -w

use Test::More;

my $TEST_DIR = $ENV{TEST_DIR} || '.';

sub touch {
  my $file = shift;
  open(my $fh, ">>$file") or return undef;
  close($fh);
  return $file;
}
sub inode {
  my $file = shift;
  return (stat($file))[1];
}
sub testcmd {
  my @cmd = @_;
  $cmd[0] = "$TEST_DIR/$cmd[0]";
  system(@cmd);
}

subtest 'basic' => sub {
  my $ver = `$TEST_DIR/ln-- --version`;
  my $rc  = $?;
  is($rc,0, "exit status");
  ok($ver,  "version ($ver)");
};

subtest 'symlink' => sub {
  ok(touch('dummy.dst'), 'touch dummy.dst');
  is(testcmd(qw(ln-- -s dummy.dst dummy.lnk)), 0, 'ln-- -s');
  is(readlink("dummy.lnk"), "dummy.dst", 'readlink');
  ok(unlink(qw(dummy.lnk dummy.dst)), 'unlink');
};

subtest 'hardlink' => sub {
  ok(touch('dummy.dst'), 'touch dummy.dst');
  is(testcmd(qw(ln-- -H dummy.dst dummy.lnk)), 0, 'ln-- -H');
  is(inode('dummy.lnk'), inode('dummy.dst'), 'inode identity');
  ok(unlink(qw(dummy.lnk dummy.dst)), 'unlink');
};

subtest 'autolink-hard' => sub {
  ok(touch('dummy.dst'), 'touch dummy.dst');
  is(testcmd(qw(ln-- dummy.dst dummy.lnk)), 0, 'ln--');
  is(inode('dummy.lnk'), inode('dummy.dst'), 'inode identity');
  ok(unlink(qw(dummy.lnk dummy.dst)), 'unlink');
};

subtest 'autolink-missing' => sub {
  ok(\! -e 'dummy.dst' || unlink('dummy.dst'), 'unlink dummy.dst');
  is(testcmd(qw(ln-- dummy.dst dummy.lnk)), 0, 'ln--');
  ok(\! -e 'dummy.dst', 'no dummy.dst');
  is(readlink('dummy.lnk'),'dummy.dst','readlink');
  ok(unlink(qw(dummy.lnk)), 'unlink');
};



done_testing();

