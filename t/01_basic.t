#!/usr/bin/perl -w

use Test::More;

subtest 'basic' => sub {
  my $ver = `./ln-- --version`;
  my $rc  = $?;
  is($rc,0, "exit status");
  ok($ver,  "version ($ver)");
};

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

subtest 'symlink' => sub {
  ok(touch('dummy.dst'), 'touch dummy.dst');
  is(system(qw(ln-- -s dummy.dst dummy.lnk)), 0, 'ln-- -s');
  is(readlink("dummy.lnk"), "dummy.dst", 'readlink');
  ok(unlink(qw(dummy.lnk dummy.dst)), 'unlink');
};

subtest 'hardlink' => sub {
  ok(touch('dummy.dst'), 'touch dummy.dst');
  is(system(qw(ln-- -H dummy.dst dummy.lnk)), 0, 'ln-- -H');
  is(inode('dummy.lnk'), inode('dummy.dst'), 'inode identity');
  ok(unlink(qw(dummy.lnk dummy.dst)), 'unlink');
};

subtest 'autolink-hard' => sub {
  ok(touch('dummy.dst'), 'touch dummy.dst');
  is(system(qw(ln-- dummy.dst dummy.lnk)), 0, 'ln--');
  is(inode('dummy.lnk'), inode('dummy.dst'), 'inode identity');
  ok(unlink(qw(dummy.lnk dummy.dst)), 'unlink');
};

subtest 'autolink-missing' => sub {
  ok(\! -e 'dummy.dst' || unlink('dummy.dst'), 'unlink dummy.dst');
  is(system(qw(ln-- dummy.dst dummy.lnk)), 0, 'ln--');
  ok(\! -e 'dummy.dst', 'no dummy.dst');
  is(readlink('dummy.lnk'),'dummy.dst','readlink');
  ok(unlink(qw(dummy.lnk)), 'unlink');
};



done_testing();

