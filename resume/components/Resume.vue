<template>
  <section id="page-top">
    <div class="container-fluid p-0">
      <section id="about" class="resume-section p-3 p-lg-5 d-flex d-column">
        <Presentation />
      </section>

      <section id="education" class="resume-section p-3 p-lg-5 d-flex flex-column">
        <Education />
      </section>

      <section id="experience" class="resume-section p-3 p-lg-5 d-flex flex-column">
        <Experience />
      </section>

      <section id="skills" class="resume-section p-3 p-lg-5 d-flex flex-column">
        <Skills />
      </section>

      <!-- <section id="interests" class="resume-section p-3 p-lg-5 d-flex flex-column">
        <Interests />
      </section> -->

      <!-- <section id="projects" class="resume-section p-3 p-lg-5 d-flex flex-column">
        <Projects />
      </section> -->
    </div>
  </section>
</template>

<script>
// import jump from 'jump.js'
// import Logo from '../components/Logo.vue'
import Presentation from '../components/Sections/Presentation';
import Education from '../components/Sections/Education';
import Experience from '../components/Sections/Experience';
import Skills from '../components/Sections/Skills';
// import Interests from '../components/Sections/Interests'
// import Projects from '../components/Sections/Projects'

export default {
  components: {
    // Logo,
    Presentation,
    Experience,
    Education,
    Skills,
    // Interests,
    // Projects,
  },
  methods: {},
};
</script>

<style></style>
