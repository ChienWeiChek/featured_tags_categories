import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { concat } from '@ember/helper';
import { LinkTo } from '@ember/routing';
import { inject as service } from '@ember/service';
import { htmlSafe } from '@ember/template';
import CategoryLogo from 'discourse/components/category-logo';
import { defaultHomepage } from 'discourse/lib/utilities';
import Category from 'discourse/models/category';
import Tag from 'discourse/models/tag';
import dIcon from 'discourse-common/helpers/d-icon';
import i18n from 'discourse-common/helpers/i18n';

export default class FeaturedCategories extends Component {
  @service router;
  @service siteSettings;
  @tracked featuredCategories = settings.featured_categories
    .split('|')
    .map((id) => Category.findById(Number(id)));

  
  <template>
    {{#if this.showOnRoute}}
      <div class='featured-categories {{concat "--" settings.plugin_outlet}}'>
        <div class='featured-categories__container'>
          <div class='featured-categories__heading'>
            <h2 class='featured-categories__title'>{{i18n
                (themePrefix 'heading')
              }}</h2>
            <LinkTo @route='discovery.categories'>
              <span class='featured-categories__link'>{{i18n
                  (themePrefix 'link')
                }}</span>
            </LinkTo>
          </div>
          <div class='featured-categories__list-container'>
            {{#each this.featuredCategories as |category|}}
              <div class='featured-categories__category-container'>
                <a
                  class='featured-categories__category-link'
                  href={{category.url}}
                >
                  {{#if category.uploaded_logo.url}}
                    <CategoryLogo @category={{category}} />
                  {{/if}}
                  <h3 class='category-name'>
                    {{#if category.read_restricted}}
                      {{dIcon 'lock'}}
                    {{/if}}
                    {{category.name}}
                  </h3>
                  <span class='category-description'>{{htmlSafe
                      category.description_excerpt
                    }}</span>
                </a>
              </div>
            {{/each}}
          </div>
        </div>
      </div>
    {{/if}}
  </template>

  get showOnRoute() {
    const currentRoute = this.router.currentRouteName;
    switch (settings.show_on) {
      case 'everywhere':
        return !currentRoute.includes('admin');
      case 'top-menu':
        const topMenu = this.siteSettings.top_menu;
        const targets = topMenu.split('|').map((opt) => `discovery.${opt}`);
        return targets.includes(currentRoute);
      case 'homepage':
        return currentRoute === `discovery.${defaultHomepage()}`;
      case 'discovery.custom':
        return currentRoute === `discovery.custom`;
      case 'discovery.latest':
        return currentRoute === `discovery.latest`;
      case 'discovery.categories':
        return currentRoute === `discovery.categories`;
      case 'discovery.top':
        return currentRoute === `discovery.top`;
      default:
        return false;
    }
  }
}
