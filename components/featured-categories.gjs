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
  @tracked featuredItems = [];

  constructor() {
    super(...arguments);
    this.loadFeaturedItems();
  }

  async loadFeaturedItems() {
    try {
      const itemsData = JSON.parse(settings.featured_tags_categories || '[]');
      console.log("🚀 ~ FeaturedCategories ~ loadFeaturedItems ~ itemsData:", itemsData)
      const items = [];

      for (const item of itemsData) {
        let entity = null;
        let type = null;
        
        if (item.category) {
          entity = Category.findById(Number(item.category));
          type = 'category';
        } else if (item.tag) {
          entity = Tag.searchContext(Number(item.tag));
          type = 'tag';
        }

        if (entity) {
          items.push({
            entity,
            type,
            backgroundColor: item.backgroundColor || '#000000',
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
            {{#each this.featuredItems as |item|}}
              <div 
                class='featured-categories__item-container'
                style={{htmlSafe (concat "background-color: " item.backgroundColor "; color: " item.textColor)}}
              >
                <a
                  class='featured-categories__item-link'
                  href={{item.entity.url}}
                  style={{htmlSafe (concat "color: " item.textColor)}}
                >
                  {{#if (and (eq item.type "category") item.entity.uploaded_logo.url)}}
                    <CategoryLogo @category={{item.entity}} />
                  {{/if}}
                  <h3 class='item-name'>
                    {{#if (and (eq item.type "category") item.entity.read_restricted)}}
                      {{dIcon 'lock'}}
                    {{/if}}
                    {{item.entity.name}}
                    {{#if (eq item.type "tag")}}
                      <span class='item-type-tag'>#</span>
                    {{/if}}
                  </h3>
                  {{#if (and (eq item.type "category") item.entity.description_excerpt)}}
                    <span class='item-description'>{{htmlSafe
                        item.entity.description_excerpt
                      }}</span>
                  {{/if}}
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

