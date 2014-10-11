package Mojolicious::Plugin::LinkEmbedder::Link::Text::HTML;

=head1 NAME

Mojolicious::Plugin::LinkEmbedder::Link::Text::HTML - HTML document

=head1 DESCRIPTION

This class inherits from L<Mojolicious::Plugin::LinkEmbedder::Link::Text>.

=cut

use Mojo::Base 'Mojolicious::Plugin::LinkEmbedder::Link::Text';
use Mojo::URL;

=head1 ATTRIBUTES

=head2 canon_url

Holds the content from "og:url" meta tag. Fallback to
L<Mojolicious::Plugin::LinkEmbedder::Link/url>.

=head2 description

Holds the content from "og:description" meta tag.

=head2 image

Holds the content from "og:image" or "og:image:url" meta tag.

=head2 title

Holds the content from "og:title" meta tag or the "title" tag.

=head2 type

Holds the content from "og:type" meta tag.

=head2 video

Holds the content from "og:video" meta tag.

=cut

has canon_url => sub { shift->url };
has description => '';
has image       => '';
has title       => '';
has type        => '';
has video       => '';

=head1 METHODS

=head2 learn

Gets the file imformation from the page meta information

=cut

sub learn {
  my ($self, $cb, @cb_args) = @_;

  $self->ua->get(
    $self->url,
    sub {
      my ($ua, $tx) = @_;
      my $dom = $tx->res->dom;
      $self->_tx($tx)->_learn_from_dom($dom) if $dom;
      $cb->(@cb_args);
    },
  );

  $self;
}

=head2 to_embed

Returns data about the HTML page in a div tag.

=cut

sub to_embed {
  my $self = shift;

  if ($self->image) {
    return <<"EMBED";
<div class="link-embedder text-html">
  <div class="link-embedder-media"><img src="@{[$self->image]}" alt="@{[$self->title]}"></div>
  <h3>@{[$self->title]}</h3>
  <p>@{[$self->description]}</p>
  <div class="link-embedder-link"><a href="@{[$self->canon_url]}" title="@{[$self->canon_url]}">@{[$self->canon_url]}</a></div>
</div>
EMBED
  }

  return $self->SUPER::to_embed(@_);
}

sub _learn_from_dom {
  my ($self, $dom) = @_;
  my $e;

  $self->audio($e->{content})       if $e = $dom->at('meta[property="og:audio"]');
  $self->description($e->{content}) if $e = $dom->at('meta[property="og:description"]');
  $self->image($e->{content})
    if $e = $dom->at('meta[property="og:image"]') || $dom->at('meta[property="og:image:url"]');
  $self->title($e->{content} || $e->text || '') if $e = $dom->at('meta[property="og:title"]') || $dom->at('title');
  $self->type($e->{content})      if $e = $dom->at('meta[property="og:type"]');
  $self->video($e->{content})     if $e = $dom->at('meta[property="og:video"]');
  $self->canon_url($e->{content}) if $e = $dom->at('meta[property="og:url"]');
  $self->media_id($self->canon_url) unless $self->media_id;
}

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

=cut

1;