<template>
  <section class="dashboard content">
    <header class="columns">
      <div class="column is-two-thirds">
        <h1 class="title is-5">
          {{ $utils.niceDate(new Date()) }}
        </h1>
      </div>
    </header>

    <section class="counts wrap">
      <div class="tile is-ancestor">
        <div class="tile is-vertical is-12">
          <div class="tile">
            <div class="tile is-parent is-vertical relative">
              <b-loading v-if="isCountsLoading" active :is-full-page="false" />
              <article class="tile is-child notification" data-cy="lists">
                <div class="columns is-mobile">
                  <div class="column is-6">
                    <p class="title">
                      <b-icon icon="format-list-bulleted-square" />
                      {{ $utils.niceNumber(counts.lists.total) }}
                    </p>
                    <p class="is-size-6 has-text-grey">
                      {{ $tc('globals.terms.list', counts.lists.total) }}
                    </p>
                  </div>
                  <div class="column is-6">
                    <ul class="no has-text-grey">
                      <li>
                        <label for="#">{{ $utils.niceNumber(counts.lists.public) }}</label>
                        {{ $t('lists.types.public') }}
                      </li>
                      <li>
                        <label for="#">{{ $utils.niceNumber(counts.lists.private) }}</label>
                        {{ $t('lists.types.private') }}
                      </li>
                      <li>
                        <label for="#">{{ $utils.niceNumber(counts.lists.optinSingle) }}</label>
                        {{ $t('lists.optins.single') }}
                      </li>
                      <li>
                        <label for="#">{{ $utils.niceNumber(counts.lists.optinDouble) }}</label>
                        {{ $t('lists.optins.double') }}
                      </li>
                    </ul>
                  </div>
                </div>
              </article><!-- lists -->

              <article class="tile is-child notification" data-cy="campaigns">
                <div class="columns is-mobile">
                  <div class="column is-6">
                    <p class="title">
                      <b-icon icon="rocket-launch-outline" />
                      {{ $utils.niceNumber(counts.campaigns.total) }}
                    </p>
                    <p class="is-size-6 has-text-grey">
                      {{ $tc('globals.terms.campaign', counts.campaigns.total) }}
                    </p>
                  </div>
                  <div class="column is-6">
                    <ul class="no has-text-grey">
                      <li v-for="(num, status) in counts.campaigns.byStatus" :key="status">
                        <label for="#" :data-cy="`campaigns-${status}`">{{ num }}</label>
                        {{ $t(`campaigns.status.${status}`) }}
                        <span v-if="status === 'running'" class="spinner is-tiny">
                          <b-loading :is-full-page="false" active />
                        </span>
                      </li>
                    </ul>
                  </div>
                </div>
              </article><!-- campaigns -->
            </div><!-- block -->

            <div class="tile is-parent relative">
              <b-loading v-if="isCountsLoading" active :is-full-page="false" />
              <article class="tile is-child notification" data-cy="subscribers">
                <div class="columns is-mobile">
                  <div class="column is-6">
                    <p class="title">
                      <b-icon icon="account-multiple" />
                      {{ $utils.niceNumber(counts.subscribers.total) }}
                    </p>
                    <p class="is-size-6 has-text-grey">
                      {{ $tc('globals.terms.subscriber', counts.subscribers.total) }}
                    </p>
                  </div>

                  <div class="column is-6">
                    <ul class="no has-text-grey">
                      <li>
                        <label for="#">{{ $utils.niceNumber(counts.subscribers.blocklisted) }}</label>
                        {{ $t('subscribers.status.blocklisted') }}
                      </li>
                      <li>
                        <label for="#">{{ $utils.niceNumber(counts.subscribers.orphans) }}</label>
                        {{ $t('dashboard.orphanSubs') }}
                      </li>
                    </ul>
                  </div><!-- subscriber breakdown -->
                </div><!-- subscriber columns -->
                <hr />
                <div class="columns" data-cy="messages">
                  <div class="column is-12">
                    <p class="title">
                      <b-icon icon="email-outline" />
                      {{ $utils.niceNumber(counts.messages) }}
                    </p>
                    <p class="is-size-6 has-text-grey">
                      {{ $t('dashboard.messagesSent') }}
                    </p>
                  </div>
                </div>
              </article><!-- subscribers -->
            </div>
          </div>
          <div class="tile is-parent relative">
            <b-loading v-if="isChartsLoading" active :is-full-page="false" />
            <article class="tile is-child notification charts">
              <div class="columns">
                <div class="column is-6">
                  <h3 class="title is-size-6">
                    {{ $t('dashboard.campaignViews') }}
                  </h3><br />
                  <chart type="line" v-if="campaignViews" :data="campaignViews" />
                </div>
                <div class="column is-6">
                  <h3 class="title is-size-6 has-text-right">
                    {{ $t('dashboard.linkClicks') }}
                  </h3><br />
                  <chart type="line" v-if="campaignClicks" :data="campaignClicks" />
                </div>
              </div>
              <div class="columns">
                <div class="column">
                  <div class="columns is-vcentered">
                    <div class="column">
                      <h3 class="title is-size-6">
                        {{ $t('dashboard.subscribersCount') }}
                      </h3>
                    </div>
                    <div class="column is-vcentered has-text-right">
                      <b-dropdown
                        class="has-text-left"
                        v-model="currentLists.subscribers"
                        @change="getSubscriberCountByList"
                        >
                        <template #trigger="{ active }">
                          <b-button
                            :label="currentLists.subscribers.name"
                            :icon-right="active ? 'menu-up' : 'menu-down'" />
                        </template>

                        <template>
                          <b-dropdown-item
                            v-for="list in this.lists"
                            :key="list.id"
                            :value="list"
                          >
                            {{ list.name }}
                          </b-dropdown-item>
                        </template>
                      </b-dropdown>
                    </div>
                  </div>
                  <chart type="line" v-if="subscriberCounts" :data="subscriberCounts" />
                  <template>
                  <div>
                    <b-field label="Select time window (months back)">
                      <div class="columns">
                        <b-field grouped class="column is-vcentered is-2 no-padding">
                          <b-numberinput
                            v-model="subscribersMonthsWindow"
                            @input="getSubscriberCountByMonths"
                            min="1"
                            controls-position="compact"
                            controls-alignment="left"
                            :editable="false"
                            style="width: 100%"
                          />
                        </b-field>
                      </div>
                    </b-field>
                  </div>
                  </template>
                </div>
              </div>
            </article>
          </div>

          <div class="tile is-parent relative">
            <b-loading v-if="isChartsLoading" active :is-full-page="false" />
            <article class="tile is-child notification charts">
              <div class="columns">
                <div class="column">
                  <div class="columns is-vcentered">
                    <div class="column">
                      <h3 class="title is-size-6">
                        {{ $t('dashboard.subscriberDomains') }}
                      </h3>
                    </div>
                    <div class="column has-text-right">
                      <b-dropdown
                        class="has-text-left"
                        v-model="currentLists.domains"
                        @change="getDomainStats"
                        >
                        <template #trigger="{ active }">
                          <b-button
                            :label="currentLists.domains.name"
                            :icon-right="active ? 'menu-up' : 'menu-down'" />
                        </template>

                        <b-dropdown-item
                            :value="{ id: undefined, name: $t('dashboard.domains.all') }"
                          >
                            {{ $t('dashboard.domains.all') }}
                        </b-dropdown-item>

                        <template>
                          <b-dropdown-item
                            v-for="list in this.lists"
                            :key="list.id"
                            :value="list"
                          >
                            {{ list.name }}
                          </b-dropdown-item>
                        </template>
                      </b-dropdown>
                    </div>
                  </div>
                  <div class="columns pie">
                    <div class="column">
                      <chart type="pie" v-if="domains" :data="domains" legend-container="legend-domains" />
                    </div>
                    <div class="column w-1/2">
                      <div class="legend" id="legend-domains" />
                    </div>
                  </div>
                </div>
              </div>
              <div class="columns">
                <div class="column">
                  <div class="columns is-vcentered">
                    <div class="column">
                      <h3 class="title is-size-6">
                        {{ $t('dashboard.subscriberCountries') }}
                      </h3>
                    </div>
                    <div class="column has-text-right">
                      <b-dropdown
                        class="has-text-left"
                        v-model="currentLists.countries"
                        @change="getCountryStats"
                        >
                        <template #trigger="{ active }">
                          <b-button
                            :label="currentLists.countries.name"
                            :icon-right="active ? 'menu-up' : 'menu-down'" />
                        </template>

                        <b-dropdown-item
                            :value="{ id: undefined, name: $t('dashboard.countries.all') }"
                          >
                            {{ $t('dashboard.countries.all') }}
                        </b-dropdown-item>

                        <template>
                          <b-dropdown-item
                            v-for="list in this.lists"
                            :key="list.id"
                            :value="list"
                          >
                            {{ list.name }}
                          </b-dropdown-item>
                        </template>
                      </b-dropdown>
                    </div>
                  </div>
                  <div class="columns pie">
                    <div class="column">
                      <chart type="pie" v-if="countries" :data="countries" legend-container="legend-countries" />
                    </div>
                    <div class="column">
                      <div class="legend" id="legend-countries" />
                    </div>
                  </div>
                </div>
              </div>
            </article>
          </div>
        </div>
      </div><!-- tile block -->
      <p v-if="settings['app.cache_slow_queries']" class="has-text-grey">
        *{{ $t('globals.messages.slowQueriesCached') }}
        <a href="https://listmonk.app/docs/maintenance/performance/" target="_blank" rel="noopener noreferer"
          class="has-text-grey">
          <b-icon icon="link-variant" /> {{ $t('globals.buttons.learnMore') }}
        </a>
      </p>
    </section>
  </section>
</template>

<style>
.columns.pie {
  max-height: 35rem;
}

.columns.pie .legend {
  height: 100%;
}

.columns.pie .legend ul {
  flex-wrap: wrap;
  height: 100%;
  overflow-y: scroll;
}
</style>

<script>
import dayjs from 'dayjs';
import Vue from 'vue';
import { mapState } from 'vuex';
import { colors, countryCodes } from '../constants';
import Chart from '../components/Chart.vue';

export default Vue.extend({
  components: {
    Chart,
  },

  data() {
    return {
      isChartsLoading: true,
      isCountsLoading: true,
      campaignViews: null,
      campaignClicks: null,
      subscriberCounts: null,
      domains: null,
      countries: null,
      counts: {
        lists: {},
        subscribers: {},
        campaigns: {},
        messages: 0,
      },
      lists: [],
      subscribersMonthsWindow: 2,
      currentLists: {
        subscribers: {
          id: -1,
          name: this.$t('globals.messages.emptyState'),
        },
        domains: {
          id: undefined,
          name: this.$t('dashboard.domains.all'),
        },
        countries: {
          id: undefined,
          name: this.$t('dashboard.countries.all'),
        },
      },
    };
  },

  methods: {
    makeChart(data) {
      if (data.length === 0) {
        return {};
      }
      return {
        labels: data.map((d) => dayjs(d.date).format('DD MMM')),
        datasets: [
          {
            data: [...data.map((d) => d.count)],
            borderColor: colors.primary,
            borderWidth: 2,
            pointHoverBorderWidth: 5,
            pointBorderWidth: 0.5,
          },
        ],
      };
    },

    makePieChart(data) {
      if (data.length === 0) {
        return {};
      }
      return {
        labels: data.map((d) => d.label),
        datasets: [
          {
            data: [...data.map((d) => d.count)],
          },
        ],
      };
    },

    getSubscriberCount(list, months) {
      this.$api.getDashboardSubscriberCounts(list.id, months).then((data) => {
        this.subscriberCounts = this.makeChart(data);
      });
    },

    getSubscriberCountByList(list) {
      this.getSubscriberCount(list, this.subscribersMonthsWindow);
    },

    getSubscriberCountByMonths(months) {
      this.getSubscriberCount(this.currentLists.subscribers, months);
    },

    getDomainStats(list) {
      this.$api.getDashboardDomainStats(list ? list.id : null).then((data) => {
        this.domains = this.makePieChart(data.map((d) => ({ label: d.domain, count: d.count })));
      });
    },

    getCountryStats(list) {
      this.$api.getDashboardCountryStats(list ? list.id : null).then((data) => {
        this.countries = this.makePieChart(data.map((d) => ({ label: d.country ? (countryCodes[d.country] || d.country) : 'Missing', count: d.count })));
      });
    },
  },

  computed: {
    ...mapState(['settings']),
    dayjs() {
      return dayjs;
    },
  },

  mounted() {
    // Pull the counts.
    this.$api.getDashboardCounts().then((data) => {
      this.counts = data;
      this.isCountsLoading = false;
    });

    // Pull the charts.
    this.$api.getDashboardCharts().then((data) => {
      this.isChartsLoading = false;
      this.campaignViews = this.makeChart(data.campaignViews);
      this.campaignClicks = this.makeChart(data.linkClicks);
    });

    this.$api.getLists({ minimal: true, per_page: 'all' }).then((data) => {
      this.lists = data.results;
      if (this.lists.length > 0) {
        [this.currentLists.subscribers] = this.lists;
        this.getSubscriberCount(this.lists[0]);
      }
    });

    this.getDomainStats();
    this.getCountryStats();
  },

});
</script>
