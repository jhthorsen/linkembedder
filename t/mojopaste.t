use Mojo::Base -strict;
use Test::Deep;
use Test::More;
use LinkEmbedder;

plan skip_all => 'TEST_ONLINE=1' unless $ENV{TEST_ONLINE};

my $embedder = LinkEmbedder->new;

my $link;
$embedder->get_p('https://p.thorsen.pm/643f88eb788d')->then(sub { $link = shift })->wait;
isa_ok($link, 'LinkEmbedder::Link::Basic');
cmp_deeply(
  $link->TO_JSON,
  {
    cache_age     => 0,
    html          => re(qr{<pre>&lt;test&gt;paste!&lt;/test&gt;</pre>}),
    provider_name => 'Thorsen',
    provider_url  => 'https://ssl.thorsen.pm/',
    title         => re(qr{ - Mojopaste}),
    type          => 'rich',
    url           => 'https://ssl.thorsen.pm/paste/643f88eb788d',
    version       => '1.0',
  },
  'https://ssl.thorsen.pm/paste/643f88eb788d'
) or note $link->_dump;

done_testing;
