package Net::MovableType;

# $Id: MovableType.pm,v 1.7 2003/07/27 12:12:36 sherzodr Exp $

use strict;
use vars qw($VERSION $errstr $errcode);
use Carp;
use XMLRPC::Lite;

($VERSION) = '$Revision: 1.7 $' =~ m/Revision:\s*(\S+)/;

# Preloaded methods go here.

sub new {
  my $class = shift;
  $class = ref($class) || $class;
  my $self = {
    _proxy => XMLRPC::Lite->proxy($_[0]),
    username => $_[1],
    password => $_[2]
  };

  return bless $self, $class
}





sub username {
  my ($self, $username) = @_;

  if ( defined $username ) {
    $self->{username} = $username;
  }
  return $self->{username}
}



*error = \&errstr;
sub errstr {
  return $errstr
}


sub errcode {
    return $errcode
}




sub password {
  my ($self, $password) = @_;

  if ( defined $password ) {
    $self->{password} = $password
  }
  return $self->{password}
}



*blogid = \&blogId;
sub blogId {
    my ($self, $blogid) = @_;

    if ( defined $blogid ) {
        $self->{blogid} = $blogid
    }
    return $self->{blogid}
}



sub resolveBlogId {
    my ($self, $blogname) = @_;

    unless ( $self->username && $self->password ) {
        croak "username and password are missing\n"
    }

    my $blogs = $self->getUsersBlogs();
    while ( my $b = shift @$blogs ) {
        if ( $b->{blogName} eq $blogname ) {
            return $b->{blogid}
        }
    }

    $errstr = "Couldn't find blog '$blogname'";
    return undef
}




*getBlogs = \&getUsersBlogs;
sub getUsersBlogs {
    my ($self, $username, $password)  = @_;

    $username = $self->username($username);
    $password = $self->password($password);

    unless ( $username && $password ) {
        croak "username and password are missing";
    }

    my $proxy   = $self->{_proxy};
    my $som     = $proxy->call('blogger.getUsersBlogs', "", $username, $password);
    my $result  = $som->result();

    unless ( defined $result ) {
        $errstr = $som->faultstring;
        $errcode = $som->faultcode;
        return undef
    }
    return $result
}






sub getUserInfo {
    my ($self, $username, $password) = @_;

    $username = $self->username($username);
    $password = $self->password($password);

    unless ( $username && $password ) {
        croak "username and/or password are missing"
    }

    my $proxy = $self->{_proxy};
    my $som   = $proxy->call('blogger.getUserInfo', "", $username, $password);
    my $result= $som->result();

    unless ( defined $result ) {
        $errstr = $som->faultstring;
        $errcode= $som->faultcode;
        return undef;
    }

    return $result
}




sub getPost {
    my ($self, $postid, $username, $password) = @_;

    $username = $self->username($username);
    $password = $self->password($password);

    unless ( $username && $password && $postid ) {
        croak "getPost() usage error"
    }

    my $proxy = $self->{_proxy};
    my $som   = $proxy->call('metaWeblog.getPost', $postid, $username, $password);
    my $result= $som->result();

    unless ( defined $result ) {
        $errstr = $som->faultstring;
        $errcode = $som->faultcode;
        return undef
    }

    return $result
}







sub getRecentPosts {
    my ($self, $numposts) = @_;

    my $blogid   = $self->blogId()     or croak "no 'blogId' defined";
    my $username = $self->username()   or croak "no 'username' defined";
    my $password = $self->password()   or croak "no 'password' defined";
    $numposts ||= 1;

    my $proxy = $self->{_proxy};
    my $som   = $proxy->call('metaWeblog.getRecentPosts', $blogid, $username, $password, $numposts);
    my $result= $som->result();

    unless ( defined $result ) {
        $errstr = $som->faultstring;
        $errcode = $som->faultcode;
        return undef
    }
    return $result
}



sub getRecentPostTitles {
    my ($self, $numposts) = @_;

    my $blogid  = $self->blogId()       or croak "no 'blogId' defined";
    my $username= $self->username()     or croak "no 'username' defined";
    my $password= $self->password()     or croak "no 'password' defined";
    $numposts ||= 1;

    my $proxy = $self->{_proxy};
    my $som   = $proxy->call('mt.getRecentPostTitles', $blogid, $username, $password, $numposts);
    my $result= $som->result();

    unless ( defined $result ) {
        $errstr = $som->faultstring;
        $errcode = $som->faultcode;
        return undef
    }
    return $result
}






*getCategories = \&getCategoryList;
sub getCategoryList {
    my ($self, $blogid, $username, $password) = @_;

    $blogid      = $self->blogId($blogid) or croak "no 'blogId' defined";
    $username   = $self->username($username) or croak "no 'username' defined";
    $password   = $self->password($password) or croak "no 'password' defined";

    my $proxy = $self->{_proxy};
    my $som   = $proxy->call('mt.getCategoryList', $blogid, $username, $password);
    my $result= $som->result();

    unless ( defined $result ) {
        $errstr = $som->faultstring;
        $errcode = $som->faultcode;
        return undef
    }
    return $result
}




sub getPostCategories {
    my ($self, $postid, $username, $password) = @_;

    $username = $self->username($username) or croak "no 'username' defined";
    $password = $self->password($password) or croak "no 'password' defined";

    unless ( $postid ) {
        croak "getPostCategories() usage error"
    }

    my $proxy = $self->{_proxy};
    my $som   = $proxy->call('mt.getPostCategories', $postid, $username, $password);
    my $result= $som->result();

    unless ( defined $result ) {
        $errstr = $som->faultring();
        $errcode= $som->faultcode();
        return undef
    }
    return $result
}



sub setPostCategories {
    my ($self, $postid, $cats) = @_;

    unless ( @$cats && $postid ) {
        croak "setPostCategories() usage error"
    }
    unless ( ref $cats ) {
        $cats = [$cats]
    }

    my $blogid = $self->blogId()    or croak "no 'blogId' set";

    my $category_list = $self->getCategoryList($blogid);
    my $post_categories = [];
    for my $cat ( @$cats ) {
        for my $c ( @$category_list ) {
            if ( lc $c->{categoryName} eq lc $cat ) {
                push @$post_categories, {categoryId=>$c->{categoryId} }
            }
        }
    }

    my $username  = $self->username() or croak "no 'username' defined";
    my $password  = $self->password() or croak "no 'password' defined";
    $postid                          or croak "setPostCategories() usage error";

    my $proxy = $self->{_proxy};
    my $som   = $proxy->call('mt.setPostCategories', $postid, $username, $password, $post_categories);
    my $result= $som->result;

    unless ( defined $result ) {
        $errstr = $som->faultstring;
        $errcode= $som->faultcode;
        return undef
    }
    return $result
}











sub supportedMethods {
    my ($self) = @_;

    my $proxy = $self->{_proxy};
    my $som   = $proxy->call('mt.supportedMethods');
    my $result= $som->result();

    unless ( defined $result ) {
        $errstr = $som->faultstring;
        $errcode= $som->faultcode;
        return undef
    }
    return $result
}



sub publishPost {
    my ($self, $postid, $username, $password) = @_;

    $username = $self->username($username) or croak "no 'username' set";
    $password = $self->password($password)  or croak "no 'password' set";

    unless ( $postid ) {
        croak "publishPost() usage error"
    }

    my $proxy = $self->{_proxy};
    my $som   = $proxy->call('mt.publishPost', $postid, $username, $password);
    my $result= $som->result();

    unless ( defined $result ) {
        $errstr = $som->faultsring;
        $errcode= $som->faultcode;
        return undef
    }
    return $result
}





sub newPost {
    my ($self, $content, $publish) = @_;

    my $blogid   = $self->blogId()   or croak "'blogId' is missing";
    my $username = $self->username() or croak "'username' is not set";
    my $password = $self->password() or croak "'password' is not set";

    unless ( $content && (ref($content) eq 'HASH') ) {
        croak "newPost() usage error"
    }

    my $proxy = $self->{_proxy};
    my $som   = $proxy->call('metaWeblog.newPost', $blogid, $username, $password, $content, $publish);
    my $result = $som->result();

    unless ( defined $result ) {
        $errstr = $som->faultstring;
        $errcode= $som->faultcode;
        return undef
    }
    return $result
}






sub editPost {
    my ($self, $postid, $content, $publish) = @_;

    my $username = $self->username() or croak "'username' is not set";
    my $password = $self->password() or croak "'password' is not set";

    unless ( $content && (ref($content) eq 'HASH') ) {
        croak "newPost() usage error"
    }

    my $proxy = $self->{_proxy};
    my $som   = $proxy->call('metaWeblog.editPost', $postid, $username, $password, $content, $publish);
    my $result = $som->result();

    unless ( defined $result ) {
        $errstr = $som->faultstring;
        $errcode= $som->faultcode;
        return undef
    }
    return $result
}






sub deletePost {
    my ($self, $postid, $publish) = @_;

    my $username = $self->username or croak "'username' not set";
    my $password = $self->password or croak "'password' not set";
    $postid                        or croak "deletePost() usage error";

    my $proxy    = $self->{_proxy};
    my $som      = $proxy->call('blogger.deletePost', "", $postid, $username, $password, $publish);
    my $result   = $som->result();

    unless ( defined $result ) {
        $errstr = $som->faultstr;
        $errcode= $som->faultcode;
        return undef
    }
    return $result
}









sub dump {
  my $self = shift;

  require Data::Dumper;
  my $d = new Data::Dumper([$self], [ref $self]);
  return $d->Dump();
}



1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Net::MovableType - light-weight MovableType client

=head1 SYNOPSIS

  use Net::MovableType;
  my $mt = new Net::MovableType('http://mt.handalak.com/cgi-bin/xmlrpc');
  $mt->username('user');
  $mt->password('secret');
  $mt->blogId(1);

  my $entries = $mt->getRecentPosts(5);
  while ( my $entry = shift @$entries ) {
    printf("[%02d] - %s\n\tURI: %s\n",
           $entry->{postid}, $entry->{title}, $entry->{'link'} )
  }

=head1 DESCRIPTION

I<Net::MovableType> is a light-weight, XML-RPC based client for MovableType's entry database.
It supports all of MovableType's remote procedures.

Using I<Net::MovableType> you can post new entries, edit existing entries, browse entries
and users blogs, and perform most of the features you can perform through accessing your
MovableType account.

Since I<Net::MovableType> uses MT's I<remote procedure call> gateway, you can do it from
any computer with an interface connection.

=head1 PROGRAMMING INTERFACE

I<Net::MovableType> promises an intuitive, user friendly, Object Oriented interface for managing
your web sites published through MovableType. Most of the method names correspond to those documented
in MovableType's Programming Interface Manual.

=head2 CREATING MT OBJECT

Before you start doing anything, you need to have a I<MovableType> object handy. You can
create a I<MovableType> object by calling C<new()> - constructor method:

    $mt = new MovableType('http://mt.handalak.com/cgi-bin/mt-xmlrpc.cgi');

Notice, you need to pass at least one argument while creating I<MT> object, that is
the location of your "mt-xmlrpc.cgi". It is very important that you get this one right.
Otherwise, I<Net::MovableType> will know neither about where your web sites are, and how to
access them.

I<MovableType> requires you to provide valid username/password pair to do most of the things.
So you need to tell I<MovableType> object about your username and passwords, so it can use
them to access the resources.

You can login in two ways; by either providing your I<username> and I<password> while creating
I<MT> object, or by calling C<username()> and C<password()> methods after creating I<MT> object:

    # creating MT object with valid username/password:
    $proxy = 'http://mt.handalak.com/cgi-bin/mt-xmlrpc.cgi';
    $mt = new MovableType($proxy, 'author', 'password');

    # or
    $mt = new MovableType($proxy);
    $mt->username('author');
    $mt->password('password');


C<username()> and C<password()> methods are used for both setting username and password,
as well as for retrieving username and password for the current logged in. Just don't pass
it any arguments should you wish to use for the latter purpose.

=head2 DEFINING A BLOG ID

As we will see in subsequent sections, some of the I<MovableType>'s methods operate on
specific web log. For defining a default web log to operate on, after setting above I<username>
and I<password>, you can also set your default blog id using C<blogId()> method:

    $mt->blogId(1);

To be able to do that, you first need to know your blog id. There are no documented ways of
retrieving your blog id, except for investigating the URL of your MovableType account panel.
Just login to your MovableType control panel (through F<mt.cgi> script). In the first screen,
you should see a list of your web logs. Click on the web log in question, and look at the
URL of the current window. In my case, it is:

    http://mt.handalak.com/cgi-bin/mt?__mode=menu&blog_id=1

Notice I<blog_id> parameter? That's the one!

Wish you didn't have to go through all those steps to find out your blog id? I<Net::MovableType>
provides C<resolveBlogId()> method, which accepts a name of the web log, and returns correct blogId:

    $blog_id = $mt->resolveBlogId('lost+found');
    $mt->blogId($blog_id);

Another way of retrieving information about your web logs is to get all the lists of your web logs
by calling C<getUsersBlogs()> method:

    $blogs = $mt->getUsersBlogs();

C<getUsersBlogs()> returns list of blogs, where each blog is represented as a hashref. Each hashref
holds such information as I<blogid>, I<blogName> and I<url>. Following example lists all the
blogs belonging to the current logged in user:

    $blogs = $mt->getUsersBlogs();
    for $b ( @$blogs ) {
        printf("[%02d] %s\n\t%s\n", $b->{blogid}, $b->{blogName}, $b->{url})
    }

=head2 POSTING NEW ENTRY

By now, you know how to login and how to define your blog_id. Now is a good time to post
a new article to your web log. That's what  C<newPost()> method is for.

C<newPost()> expects at least a single argument, which should be a reference to a hash
containing all the details of your new entry. First, let's define a new entry to be posted
on our web log:

    $entry = {
        title       => "Hello World from Net::MovableType",
        description => "Look ma, no hands!"
    };

Now, we can pass above C<$entry> to our C<newPost()> method:

    $mt->newPost($entry);

In the above example, I<description> field corresponds to Entry Body field of MovableType.
This is accessible from within your templates through I<MTEntryBody> tag. MovableType allows
you to define more entry properties than we did above. Following is the list of all the
attributes we could've defined in our above C<$entry>:

=over 4

=item dateCreated

I<Authored Date> attribute of the entry. Format of the date should be in I<ISO.8601> format

=item mt_allow_comments

Should comments be allowed for this entry

=item mt_allow_pings

should pings be allowed for this entry

=item mt_convert_breaks

Should it use "Convert Breaks" text formatter?

=item mt_text_more

Extended entry

=item mt_excerpt

Excerpt of the entry

=item mt_keywords

Keywords for the entry

=item mt_tb_ping_urls

List of track back ping urls

=back

Above entry is posted to your MT database. But you still don't see it in your weblog, do you?
It's because, the entry is still not published. There are several ways of publishing an entry.
If you pass a true value to C<newPost()> as the second argument, it will publish your entry
automatically:

    $mt->newPost($entry, 1);

You can also publish your post by calling C<publishPost()> method. C<publishPost()>, however, needs
to know I<id> of the entry to publish. Our above C<newPost()>, luckily, already returns this information,
which we've been ignoring until now:

    my $new_id = $mt->newPost($entry);
    $mt->publishPost($new_id);

You can also publish your post later, manually, by simply rebuilding your web log from within
your MT control panel.

=head2 ENTRY CATEGORIES

I<MovableType> also allows entries to be associated with specific category, or even with
multiple categories. For example, above C<$entry>, we just published, may belong to category "Tutorials".

Unfortunately, structure of our C<$entry> doesn't have any slots for defining its categories.
This task is performed by a separate procedure, C<setPostCategories()>.

C<setPostCategories()> expects two arguments. First should be I<postid> of the post to assign
categories to, and second argument should either be a name of the primary category, or
a list of categories in the form of an arrayref. In the latter case, the first category mentioned
becomes entry's primary category.

For example, let's re-post our above C<$entry>, but this time assign it to "Tutorials" category:

    $new_id = $mt->newPost($entry, 0);  # <-- not publishing it yet
    $mt->setPostCategories($new_id, "Tutorials");
    $mt->publishPost($new_id);

We could also assign a single entry to multiple categories. Say, to both "Tutorials" and
"Daily Endeavors". But say, we want "Daily Endeavors" to be the primary category for this entry:

    $new_id = $mt->newPost($entry, 0);  # <-- not publishing it yet
    $mt->setPostCategories($newPid, ["Daily Endeavors", "Tutorials"]);
    $mt->publishPost($new_id);


Notice, in above examples we made sure that C<newPost()> method didn't publish the entry
by passing it false value as the second argument. If we published it, we again would end
up having to re-publish the entry after calling C<setPostCategories()>, thus wasting
unnecessary resources.

=head2 BROWSING ENTRIES

Say, you want to be able to retrieve a list of entries from your web log. There couple of ways
for doing this. If you just want titles of your entries, consider using C<getRecentPostTitles()>
method. C<getRecentPostTitles()> returns an array of references to a hash, where each hashref
contains fields I<dateCreated>, I<userid>, I<postid> and I<title>.

C<getRecentPostTitles()> accepts a single argument, denoting the number of recent entries to retrieve.
If you don't pass any arguments, it defaults to I<1>:

    $recentTitles = $mt->getRecentPostTitles(10);
    for my $post ( @$resentTitles ) {
        printf("[%03d] %s\n", $post->{postid}, $post->{title})
    }

Remember, even if you don't pass any arguments to C<getRecentPostTitles()>, it still returns an array
of hashrefs, but this array will hold only one element:

    $recentTitle = $mt->getRecentPostTitles();
    printf("[%03d] %s\n", $recentTitles->[0]->{postid}, $recentTitles->[0]->{title});

Another way of browsing a list of entries, is through C<getRecentPosts()> method. Use of this method
is identical to above-discussed C<getRecentPostTitles()>, but this one returns a lot more information
about each post. It can accept a single argument, denoting number of recent entries to retrieve.

Elements of the returned hash are compatible with the C<$entry> we constructed in earlier sections.

=head2 RETREIVING A SINGLE ENTRY

Sometimes, you may want to retrieve a specific entry from your web log. That's what C<getPost()>
method does. It accepts a single argument, denoting an id of the post, and returns a hashref, keys of
which are compatible with the C<$entry> we built in earlier sections (see POSTING NEW ENTRY):

    my $post = $mt->getPost(134);
    printf("Title: %s (%d)\n", $post->{title}, $post->{postid});
    printf("Excerpt: %s\n\n", $post->{mt_excerpt} );
    printf("BODY: \n%s\n", $post->{description});
    if ( $post->{mt_text_more} ) {
        printf("\nEXTENDED ENTRY:\n", $post->{mt_text_more} );
    }

=head2 EDITING ENTRY

Editing an entry means to re-post the entry. This is done almost the same way as the entry
has been published. C<editPost()> method, which is very similar in use to C<newPost()>, but accepts
a I<postid> denoting the id of the post that you are editing. Second argument should be a hashref,
describing fields of the entry. Structure of this hashref was discussed in earlier sections (see
POSTING NEW ENTRY):

    $mt->editPost($postid, $entry)


=head2 DELETING ENTRY

You can delete a specific entry from your database (and weblog) using C<deletePost()>
method. C<deletePost()> accepts at least one argument, which is the id of the post to be
deleted:

    $mt->deletePost(122);   # <-- deleting post 122


By default entries are deleted form the database, not from your web log. They usually
fade away once your web log is rebuilt. However, it may be more desirable to remove
the entry both from the database and from the web site at the same time.

This can be done by passing a true value as the second argument to C<deletePost()>. This
ensures that your pages pertaining to the deleted entry are rebuilt:

    $mt->deletePost(122, 1); # <-- delet post 122, and rebuilt the web site

=head2 ERROR HANDLING

If you noticed, we didn't even try to check if eny of our remote procedure calls
succeeded. This is to keep the examples as clean as possible.

For examlpe, consider the following call:

    $new_id = $mt->newPost($entry, 1);

There is no guaranteed that the above entry will be posted, or published.
You username/password might be wrong, or you made a mistake while defining your
I<mt-xmlrpc> gateway? You may never know untill its too late.

That's why you should always check the return value of the methods that make a remote
procedure call.

All the methods return true on success, C<undef> otherwise. Error message from the latest
procedure call is available by calling C<errstr()> static class method. Code of the error
message (not always as useful) can be retrieved through C<errcode()> static class method:

    $new_id = $mt->newPost($entry, 1);
    unless ( defined $new_id ) {
        die $mt->errstr
    }

or:

    $new_id = $mt->newPost($entry, 1) or die $mt->errstr;

=head1 TODO

Should implement a caching mechanism

=head1 COPYRIGHT

Copyright (C) 2003, Sherzod B. Ruzmetov. All rights reserved.

This library is a free software, and can be modified and distributed under the same
terms as Perl itself.

=head1 AUTHOR

Sherzod Ruzmetov E<lt>sherzodr AT cpan.orgE<gt>

http://author.handalak.com/

=head1 SEE ALSO

L<Net::Blogger>

=cut
