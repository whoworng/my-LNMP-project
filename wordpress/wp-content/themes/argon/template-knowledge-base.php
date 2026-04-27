<?php
/*
Template Name: 配置知识库
Template Post Type: page
*/

get_header();

the_post();
$page_title = get_the_title();
$page_intro = get_the_content();
$knowledge_category = get_category_by_slug("config-vault");
$knowledge_category_id = $knowledge_category ? (int) $knowledge_category->term_id : 0;
$paged = max(1, (int) get_query_var("paged"));

$query_args = array(
    "post_type" => "post",
    "post_status" => "publish",
    "posts_per_page" => 12,
    "paged" => $paged,
);

if ($knowledge_category_id > 0) {
    $query_args["cat"] = $knowledge_category_id;
}

$knowledge_query = new WP_Query($query_args);
$total_posts = (int) $knowledge_query->found_posts;
?>

<div class="page-information-card-container">
    <div class="page-information-card card bg-white shadow-sm border-0 knowledge-base-hero-card">
        <div class="card-body">
            <span class="knowledge-base-hero-kicker">CONFIG VAULT</span>
            <h1 class="knowledge-base-hero-title"><?php echo esc_html($page_title); ?></h1>
            <p class="knowledge-base-hero-text">
                这里集中整理站点的代码配置、部署片段与排障经验。以后新增文章时，勾选分类“配置知识库”，这里会按主页面同款文章列表自动展示。
            </p>
            <div class="knowledge-base-hero-meta">
                <span><i class="fa fa-files-o"></i> <?php echo esc_html($total_posts); ?> 篇条目</span>
                <?php if ($knowledge_category_id > 0) { ?>
                    <span><i class="fa fa-folder-open-o"></i> 分类已绑定</span>
                <?php } ?>
                <span><i class="fa fa-window-restore"></i> 列表样式已与首页统一</span>
            </div>
        </div>
    </div>
</div>

<?php get_sidebar(); ?>

<div id="primary" class="content-area knowledge-base-area">
    <main id="main" class="site-main article-list article-list-home knowledge-base-main" role="main">
        <?php if (trim(wp_strip_all_tags($page_intro)) !== "") { ?>
            <section class="knowledge-base-intro card bg-white shadow-sm border-0">
                <div class="card-body">
                    <?php echo apply_filters("the_content", $page_intro); ?>
                </div>
            </section>
        <?php } ?>

        <?php if ($knowledge_query->have_posts()) { ?>
            <?php while ($knowledge_query->have_posts()) { ?>
                <?php
                $knowledge_query->the_post();
                get_template_part("template-parts/content-preview", get_option("argon_article_list_layout", "1"));
                ?>
            <?php } ?>
        <?php } else { ?>
            <article class="knowledge-base-empty card bg-white shadow-sm border-0">
                <div class="card-body">
                    <h2>知识库还没有条目</h2>
                    <p>去 WordPress 后台新增文章，勾选分类“配置知识库”，并把关键配置写进摘要，这里就会按首页样式自动展示。</p>
                </div>
            </article>
        <?php } ?>

        <?php if ($knowledge_query->max_num_pages > 1) { ?>
            <div class="knowledge-base-pagination">
                <?php
                echo paginate_links(array(
                    "total" => $knowledge_query->max_num_pages,
                    "current" => $paged,
                    "type" => "list",
                    "prev_text" => "«",
                    "next_text" => "»",
                ));
                ?>
            </div>
        <?php } ?>

        <?php wp_reset_postdata(); ?>
    </main>
</div>

<?php get_footer(); ?>
