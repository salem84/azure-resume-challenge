<template>
  <div class="counter">
    <template v-if="$fetchState.pending">
      <span>{{ message }}</span>
    </template>
    <template v-else>
      <span>{{ users }}</span>
    </template>
  </div>
</template>

<script>
//import Stats from '~/models/stats';

export default {
  data() {
    return {
      message: 'Welcome',
      users: Object,
    };
  },
  async fetch() {
    this.$toast.show('Welcome!!');
    let url = `${process.env.functionBaseUrl}/api/counter`;
    this.users = await fetch(url).then((res) => res.json());
    this.$toast.success(`You are ${this.users.totalCount}`);
  },
  fetchOnServer: false,
};
</script>
