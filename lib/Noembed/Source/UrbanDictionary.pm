package Noembed::Source::UrbanDictionary;

use Web::Scraper;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{re} = qr{http://(?:www\.)urbandictionary\.com/define\.php\?term=.+}i;
  $self->{scraper} = scraper {
    process "td.word", "words[]" => "TEXT";
    process "div.definition", "definitions[]" => "HTML";
  };
}

sub matches {
  my ($self, $url) = @_;
  $url =~ $self->{re};
}

sub filter {
  my ($self, $body) = @_;

  my $data = $self->{scraper}->scrape($body);

  my $html = "<div class=\"urban-dictionary-def\">$data->{definitions}->[0]</div>";

  my $title = $data->{words}->[0];
  $title =~ s/^\s//ms;
  $title =~ s/\s+$//ms;

  return +{
    title => $title,
    html  => $html,
  }
}

sub provider_name { "Urban Dictionary" }

sub style {
  $self->{style} ||= do {
    local $/;
    <DATA>;
  };
}

1;

__DATA__
.urban-dictionary-def {
  border: 1px solid #ccc;
  font-size: 12px;
  padding: 5px;
}
