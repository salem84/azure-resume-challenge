<template>
  <div>
    <div
      class="card shadow mb-5 bg-white rounded"
      :class="projectInfo.customCssClass"
      style="width: 80%; text-align: center"
    >
      <a :href="projectInfo.siteUrl">
        <img class="card-img-top" :src="projectInfo.image" alt="logo" />
      </a>
      <div class="card-body">
        <h5 class="card-title">
          <a :href="projectInfo.siteUrl">{{ projectInfo.name }}</a>
        </h5>
        <p class="card-text">
          {{ projectInfo.description }}
        </p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  // eslint-disable-next-line vue/require-prop-types
  props: ['projectInfo'],
  data() {
    return {};
  },
};
</script>

<style>
.card {
  border: none;
}

.card-horizontal {
  flex-direction: row;
}

.card-body,
.card-title {
  color: #868e96;
}
</style>
