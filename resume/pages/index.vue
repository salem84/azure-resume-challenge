<template>
  <section>
    <nav id="sideNav" class="navbar navbar-expand-lg navbar-dark bg-primary fixed-top">
      <a class="navbar-brand js-scroll-trigger" href="#page-top">
        <span class="d-block d-lg-none">Resume Giorgio Lasala</span>
        <span class="d-none d-lg-block">
          <img class="img-fluid img-profile rounded-circle mx-auto mb-2" src="/images/profile.png" alt="" />
        </span>
      </a>
      <button
        class="navbar-toggler"
        type="button"
        data-toggle="collapse"
        data-target="#navbarSupportedContent"
        aria-controls="navbarSupportedContent"
        aria-expanded="false"
        aria-label="Toggle navigation"
      >
        <span class="navbar-toggler-icon"></span>
      </button>
      <div id="navbarSupportedContent" class="collapse navbar-collapse">
        <ul class="navbar-nav">
          <li class="nav-item">
            <a class="nav-link js-scroll-trigger" href="#" @click="jumpTo('#about')">{{ $t('links.about') }}</a>
          </li>
          <li class="nav-item">
            <a class="nav-link js-scroll-trigger" href="#" @click="jumpTo('#education')">{{ $t('links.education') }}</a>
          </li>
          <li class="nav-item">
            <a class="nav-link js-scroll-trigger" href="#" @click="jumpTo('#experience')">{{
              $t('links.experience')
            }}</a>
          </li>
          <li class="nav-item">
            <a class="nav-link js-scroll-trigger" href="#" @click="jumpTo('#skills')">{{ $t('links.skills') }}</a>
          </li>
          <li class="nav-item">
            <a class="nav-link js-scroll-trigger" href="#" @click="jumpTo('#interests')">{{ $t('links.interests') }}</a>
          </li>
          <li class="nav-item">
            <a class="nav-link js-scroll-trigger" href="#" @click="jumpTo('#projects')">{{ $t('links.projects') }}</a>
          </li>
          <li class="nav-item">
            <div style="position: fixed; bottom: 10px; left: 10px; z-index: 1000">
              <DarkModeBtn />
              <Counter />
            </div>
          </li>
          <li class="nav-item">
            <div style="position: fixed; bottom: 10px; right: 10px; z-index: 1000">
              <nuxt-link class="btn btn-light" :to="switchLocalePath('en')">EN</nuxt-link>
              <!-- <nuxt-link class="btn btn-light" :to="switchLocalePath('it')"
                >IT</nuxt-link> -->
            </div>
          </li>
        </ul>
      </div>
    </nav>

    <div class="resume">
      <Resume />
    </div>
  </section>
</template>

<script>
import Resume from '@/components/Resume';
import DarkModeBtn from '@/components/DarkModeBtn';
import Counter from '@/components/Counter';
import jump from 'jump.js';

export default {
  components: {
    Resume,
    DarkModeBtn,
    Counter,
  },
  head() {
    return {
      title: 'Giorgio Lasala',
    };
  },
  methods: {
    jumpTo(element) {
      jump(element);
    },
  },
};
</script>

<style scoped>
h1 {
  font-size: 3rem;
  line-height: 5.5rem;
}
@media (min-width: 992px) {
  .resume {
    padding-top: 0;
    padding-left: 17rem;
  }
}
</style>
