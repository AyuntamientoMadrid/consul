<?php $helper->content_for("body_class", "home-page"); ?>

<?php if(true === false) {
  $helper->provide("title", $helper->t("meta_tags.welcome_index." + Budget->current()->phase() + ".title"));
  $helper->provide("meta_description", $helper->t("meta_tags.welcome_index." + Budget->current_budget()->phase() + ".description"));
} else {
  $helper->provide("title", $helper->t("meta_tags.welcome_index.title"));
  $helper->provide("meta_description", $helper->t("meta_tags.welcome_index.description"));
}

$helper->provide("tracking_page_number", "23");

$helper->content_for(("canonical"), function() {
  echo $helper->render("shared/canonical", array("href" => $controller->root_url()));
});

if(true === false) {
  $helper->provide(("social_media_meta_tags"), function() {
    echo $helper->render("shared/social_media_meta_tags",
      array(
        "social_url"        => $controller->root_url(),
        "twitter_image_url" => "social_media_budgets_2018_balloting_twitter.png",
        "og_image_url"      => "social_media_budgets_2018_balloting.png"
      )
    );
  });
} else {
  $helper->provide(("social_media_meta_tags"), function() {
    echo $helper->render("shared/social_media_meta_tags",
      array(
        "social_url"         => $controller->root_url(),
        "social_title"       => $helper->t("landings.signup.title"),
        "social_description" => $helper->t("landings.signup.description"),
        "twitter_image_url"  => "social_media_twitter.jpg",
        "og_image_url"       => "social_media.jpg"
      )
    );
  });
}

echo $helper->render("header", array("header" => $at->header()));
?>

<main class="welcome">

  <h1 class="show-for-sr"><?php echo $helper->t("welcome.title"); ?></h1>

  <?php echo $helper->render("feeds"); ?>

  <div class="row">
    <?php if($at->cards()->any() == true) { ?>
      <div class="small-12 column <?php if($helper->feed_processes_enabled() === true) { echo "large-8"; } ?>">
        <?php echo $helper->render("cards"); ?>
      </div>
    <?php } ?>

    <div class="small-12 large-4 column">
      <?php echo $helper->render("processes"); ?>
    </div>
  </div>

  <?php if(($feature["user"]["recommendations"] && ($at->recommended_debates()->present() || $at->recommended_proposals()->present())) === true) {
    echo $helper->render("recommended",
      array(
        "recommended_debates"   => $at->recommended_debates(),
        "recommended_proposals" => $at->recommended_proposals()
      )
    );
  } ?>
</main>
