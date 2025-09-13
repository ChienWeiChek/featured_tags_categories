import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { concat } from '@ember/helper';
import { LinkTo } from '@ember/routing';
import { inject as service } from '@ember/service';
import { htmlSafe } from '@ember/template';
import CategoryLogo from 'discourse/components/category-logo';
import { defaultHomepage } from 'discourse/lib/utilities';
import Category from 'discourse/models/category';
import dIcon from 'discourse-common/helpers/d-icon';
import i18n from 'discourse-common/helpers/i18n';

export default class FeaturedCategories extends Component {
  @service router;
  @service siteSettings;
  @tracked featuredItems = [];

  constructor() {
    super(...arguments);
    this.loadFeaturedItems();
  }

  async loadFeaturedItems() {
    try {
      const itemsData = JSON.parse(settings.featured_tags_categories || '[]');
      const items = [];

      for (const item of itemsData) {
        let entity = null;
        let type = null;
        
        if (item.category) {
          entity = Category.findById(Number(item.category));
          type = 'category';
        } else if (item.tag) {
          // For tags, we create a simple object with name and URL
          entity = {
            name: item.tag,
            url: `/tag/${item.tag}`
          };
          type = 'tag';
        }

        if (entity) {
          items.push({
            entity,
            type,
            backgroundColor: item.backgroundColor || '#fffff',
            textColor: item.textColor || '#000000'
          });
        }
      }

      this.featuredItems = items;
    } catch (error) {
      console.error('Error parsing featured_tags_categories:', error);
      this.featuredItems = [];
    }
  }

  <template>
    {{#if this.showOnRoute}}
      <div class='featured-categories-tags {{concat "--" settings.plugin_outlet}}'>
        <div class='featured-categories-tags__container'>
          <div class='featured-categories-tags__heading'>
            <h2 class='featured-categories-tags__title'>{{i18n
                (themePrefix 'heading')
              }}</h2>
            <LinkTo @route='discovery.categories'>
              <span class='featured-categories-tags__link'>{{i18n
                  (themePrefix 'link')
                }}</span>
            </LinkTo>
          </div>
          <div class='featured-categories-tags__list-container'>
            {{#each this.featuredItems as |item|}}
              <div 
                class='featured-categories-tags__item-container'
                style={{htmlSafe (concat "background-color: " item.backgroundColor)}}
              >
                <a
                  class='featured-categories-tags__item-link'
                  href={{item.entity.url}}
                >
                  <h3 
                    class='item-name' 
                    style={{htmlSafe (concat "color: " item.textColor)}}
                  >
                    {{item.entity.name}}
                  </h3>
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
