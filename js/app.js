/**
 * Hunter Wetlands Centre - Visitor Guide App
 */

(function () {
  'use strict';

  // ===== Walk Detail Data =====
  const walkDetails = {
    sensory: {
      title: 'Sensory Trail',
      difficulty: 'Easy',
      duration: '15-20 min',
      tags: ['Easy', 'Family Friendly', 'Accessible'],
      description: 'The Sensory Trail is a hands-on nature experience designed to engage all your senses. Informative signs along the trail explain what plants to touch, smell and discover, making it a wonderful introduction to the wetlands for visitors of all ages.',
      highlights: [
        { name: 'Touch & Smell Stations', desc: 'Interactive signs guide you to feel bark textures, smell aromatic leaves, and listen to the sounds of the wetlands.' },
        { name: 'Native Plant Garden', desc: 'Discover a curated collection of native plants with labels explaining their ecological role and sensory qualities.' },
        { name: 'Totem Pole', desc: 'Look for the hand-carved totem pole along this trail, designed to represent the animals and plants of this habitat.' },
        { name: 'Quiet Listening Point', desc: 'Stop and listen to the chorus of birdcalls and frog sounds that fill the wetlands.' },
      ],
      tips: 'This is a great first trail for young children. The trail is mostly flat and accessible. Allow extra time for little ones to explore each station.',
    },
    'bush-tucker': {
      title: 'Bush Tucker Garden Trail',
      difficulty: 'Easy',
      duration: '20-30 min',
      tags: ['Easy', 'Cultural', 'Educational'],
      description: 'Journey through the Bush Tucker Garden and learn how Aboriginal peoples have used native plants for food, medicine and tools for thousands of years. Interpretive signs throughout reveal traditional uses and cultural stories.',
      highlights: [
        { name: 'Bush Tucker Garden', desc: 'A curated garden of native edible and useful plants with signs explaining Aboriginal names and traditional uses.' },
        { name: 'Medicinal Plants', desc: 'Learn about plants used traditionally for healing, including tea tree (Melaleuca) which gives the nearby swamp its name.' },
        { name: 'Food Plants', desc: 'Discover which native fruits, seeds and roots were important food sources for local Aboriginal communities.' },
        { name: 'Totem Poles', desc: 'Hand-carved totem poles depicting the natural interactions between plants and animals in this habitat.' },
      ],
      tips: 'Take your time reading the interpretive signs - they contain fascinating information about thousands of years of Aboriginal plant knowledge.',
    },
    'egret-tower': {
      title: 'Egret Tower & Melaleuca Swamp Walk',
      difficulty: 'Easy',
      duration: '30-40 min',
      tags: ['Easy', 'Birdwatching', 'Photography'],
      description: 'Walk through to the iconic Egret Tower, a 2-storey observation structure overlooking Melaleuca Swamp. This freshwater swamp forest is used as a heronry by 4 egret species and serves as an evening roost for Australian White Ibis and Straw-necked Ibis.',
      highlights: [
        { name: 'Melaleuca Forest', desc: 'Walk through a beautiful corridor of Melaleuca (paperbark) trees that create the swamp forest habitat.' },
        { name: 'Egret Tower', desc: 'Climb the 2-storey tower for a bird\'s-eye view down into the heronry where egrets nest and roost. Look for Great Egret, Little Egret, Intermediate Egret and Cattle Egret.' },
        { name: 'Ibis Roost', desc: 'In the late afternoon, watch hundreds of Australian White Ibis and Straw-necked Ibis return to their evening roost in the Melaleuca canopy.' },
        { name: 'Boardwalk Section', desc: 'A raised boardwalk section keeps your feet dry while crossing through the wettest parts of the swamp forest.' },
      ],
      tips: 'For the best birdwatching, visit in the early morning when egrets are active, or late afternoon when ibis return to roost. Bring binoculars!',
    },
    'bird-hide': {
      title: 'Bird Hide & Boardwalk Circuit',
      difficulty: 'Easy',
      duration: '40-50 min',
      tags: ['Easy', 'Birdwatching', 'Photography'],
      description: 'Visit the purpose-built bird hides scattered across the wetlands, connected by boardwalks and observation points. The star attraction is the Water Ribbon Swamp hide, built directly over the water for intimate wildlife encounters.',
      highlights: [
        { name: 'Water Ribbon Swamp Hide', desc: 'The jewel of the trail - a bird hide built over the water giving you eye-level views of waterbirds, ducks and grebes going about their daily lives.' },
        { name: 'Freshwater Pond Lookout', desc: 'Scan the deeper ponds for Black Swan, Hardhead, Australian Shoveler and the rare Freckled Duck.' },
        { name: 'Boardwalk Circuit', desc: 'Elevated boardwalks connect the hides, keeping you above the wetland and providing different vantage points.' },
        { name: 'Observation Decks', desc: 'Multiple observation decks allow you to pause and watch the comings and goings of waterbirds across the ponds.' },
        { name: 'Mudflat Margins', desc: 'Depending on water levels, exposed mudflats attract migratory shorebirds - look for sandpipers and stilts.' },
      ],
      tips: 'Stay quiet in the bird hides and you\'ll be rewarded. Birds quickly forget you\'re there and come very close. Early morning light is best for photography.',
    },
    'full-loop': {
      title: 'Full Wetlands Loop',
      difficulty: 'Moderate',
      duration: '1.5-2 hours',
      tags: ['Moderate', 'Nature', 'All Habitats'],
      description: 'The complete 4km trail network takes you through every habitat on the site - from freshwater ponds and marshes to woodland and swamp forest. This is the best way to experience the full diversity of the wetlands and see all the hand-carved totem poles.',
      highlights: [
        { name: 'Visitor Centre Start', desc: 'Begin at the visitor centre and head out along the main trail. Pick up a map at reception to guide your route.' },
        { name: 'Sensory Trail & Bush Tucker Garden', desc: 'Start with the interactive trails near the visitor centre before heading deeper into the wetlands.' },
        { name: 'Bird Hides & Boardwalks', desc: 'Visit all four purpose-built bird hides including the Water Ribbon Swamp hide over the water.' },
        { name: 'Melaleuca Swamp & Egret Tower', desc: 'Pass through the paperbark forest and climb the tower for aerial views of the heronry.' },
        { name: 'Woodland Section', desc: 'The trail passes through drier woodland habitat, home to bush birds, lizards and the Northern Brown Bandicoot.' },
        { name: 'Ironbark Creek Viewpoint', desc: 'Views across Ironbark Creek and the tidal mangrove habitat on the wetlands boundary.' },
        { name: 'Totem Pole Trail', desc: 'Collect sightings of all the hand-carved totem poles - each uniquely designed for the habitat it stands in.' },
      ],
      tips: 'Allow plenty of time and bring water. You can shorten the loop by cutting through connector paths. The trail is mostly flat but some sections may be muddy after rain.',
    },
    canoe: {
      title: 'Ironbark Creek Canoe Trail',
      difficulty: 'Moderate',
      duration: '2 hours',
      tags: ['Moderate', 'Paddle', 'Ages 4+'],
      description: 'Paddle 2km along Ironbark Creek to the rainforest shelter and back. Hire a 2 or 3 person canoe from reception and explore the waterways that wind through the heart of the wetlands. A truly unique perspective on this special place.',
      highlights: [
        { name: 'Canoe Launch', desc: 'Launch from the jetty near the visitor centre. Staff will brief you on the route and safety procedures.' },
        { name: 'Ironbark Creek', desc: 'Paddle along the tidal creek, passing through mangroves and overhanging trees. Watch for Water Rats, kingfishers and cormorants.' },
        { name: 'Mangrove Section', desc: 'Navigate through a corridor of mangroves that provide important nursery habitat for fish and crustaceans.' },
        { name: 'Rainforest Shelter', desc: 'Your destination - a sheltered rest point surrounded by remnant rainforest. A great spot to pause and enjoy the surroundings before heading back.' },
      ],
      tips: 'Closed-in shoes mandatory. Check with reception first as canoe hire is only available during suitable tidal conditions. Bring sun protection and water. Available for ages 4+.',
    },
    orienteering: {
      title: 'Orienteering Course',
      difficulty: 'Moderate',
      duration: '1-2 hours',
      tags: ['Moderate', 'Adventure', 'All Abilities'],
      description: 'Test your navigation skills on the orienteering course designed by Newcastle Orienteering Club. Use a topographical map to find all the checkpoints scattered across the 45-hectare site. No compass required!',
      highlights: [
        { name: 'Get Your Map', desc: 'Pick up a topographical map from reception or download one from the website before you start.' },
        { name: 'Checkpoint Navigation', desc: 'Use the map to navigate between checkpoints placed at key locations across the site. Each checkpoint teaches you something about the area.' },
        { name: 'Diverse Terrain', desc: 'The course takes you through a variety of habitats and terrain types, from open grassland to woodland trails.' },
        { name: 'Personal Challenge', desc: 'Time yourself and try to beat your record on your next visit! Great for scouts, school groups and competitive families.' },
      ],
      tips: 'No compass needed but bring a pen to record your checkpoint finds. The course can be tackled at walking pace or as a timed challenge. Great for all ages and abilities.',
    },
  };

  // ===== DOM Elements =====
  const splash = document.getElementById('splash');
  const app = document.getElementById('app');
  const pageContainer = document.getElementById('page-container');
  const headerTitle = document.getElementById('header-title');
  const btnBack = document.getElementById('btn-back');
  const navItems = document.querySelectorAll('.nav-item');

  // ===== State =====
  let currentPage = 'home';
  let pageHistory = [];

  // ===== Initialize =====
  function init() {
    // Show splash then reveal app
    setTimeout(function () {
      splash.classList.add('fade-out');
      setTimeout(function () {
        splash.style.display = 'none';
        app.classList.remove('hidden');
      }, 500);
    }, 1500);

    bindEvents();
  }

  // ===== Event Binding =====
  function bindEvents() {
    // Bottom nav
    navItems.forEach(function (item) {
      item.addEventListener('click', function () {
        var page = this.getAttribute('data-page');
        navigateTo(page, true);
      });
    });

    // Feature cards (home page)
    document.querySelectorAll('.feature-card').forEach(function (card) {
      card.addEventListener('click', function () {
        var page = this.getAttribute('data-page');
        navigateTo(page);
      });
    });

    // Walk cards
    document.querySelectorAll('.walk-card').forEach(function (card) {
      card.addEventListener('click', function () {
        var walkId = this.getAttribute('data-walk');
        showWalkDetail(walkId);
      });
    });

    // Wildlife toggles
    document.querySelectorAll('.wildlife-header').forEach(function (header) {
      header.addEventListener('click', function () {
        var targetId = this.getAttribute('data-toggle');
        var target = document.getElementById(targetId);
        if (target) {
          target.classList.toggle('hidden');
          this.classList.toggle('open');
        }
      });
    });

    // Back button
    btnBack.addEventListener('click', goBack);
  }

  // ===== Navigation =====
  function navigateTo(pageId, isNavClick) {
    if (pageId === currentPage && pageId !== 'home') return;

    // Hide all pages
    document.querySelectorAll('.page').forEach(function (p) {
      p.classList.remove('active');
    });

    // Show target page
    var targetPage = document.getElementById('page-' + pageId);
    if (targetPage) {
      targetPage.classList.add('active');
    }

    // Update nav
    navItems.forEach(function (item) {
      item.classList.toggle('active', item.getAttribute('data-page') === pageId);
    });

    // Update header
    var titles = {
      home: 'Hunter Wetlands',
      walks: 'Walks & Trails',
      wildlife: 'Wildlife Guide',
      activities: 'Activities',
      'visitor-info': 'Visitor Info',
      about: 'About & Conservation',
    };
    headerTitle.textContent = titles[pageId] || 'Hunter Wetlands';

    // Handle back button
    if (isNavClick) {
      pageHistory = [];
      btnBack.classList.add('hidden');
    } else {
      pageHistory.push(currentPage);
      btnBack.classList.remove('hidden');
    }

    if (pageId === 'home') {
      pageHistory = [];
      btnBack.classList.add('hidden');
    }

    currentPage = pageId;

    // Scroll to top
    pageContainer.scrollTo(0, 0);
    window.scrollTo(0, 0);
  }

  // ===== Walk Detail =====
  function showWalkDetail(walkId) {
    var walk = walkDetails[walkId];
    if (!walk) return;

    var container = document.getElementById('walk-detail-content');
    var tagsHtml = walk.tags
      .map(function (t) {
        return '<span class="tag">' + t + '</span>';
      })
      .join('');

    var poisHtml = walk.highlights
      .map(function (poi, i) {
        return (
          '<div class="poi-item">' +
          '<div class="poi-number">' + (i + 1) + '</div>' +
          '<div class="poi-text">' +
          '<h4>' + poi.name + '</h4>' +
          '<p>' + poi.desc + '</p>' +
          '</div>' +
          '</div>'
        );
      })
      .join('');

    container.innerHTML =
      '<div class="walk-detail">' +
      '<div class="walk-detail-header">' +
      '<h2>' + walk.title + '</h2>' +
      '<div class="walk-detail-tags">' + tagsHtml + '</div>' +
      '</div>' +
      '<div class="walk-detail-body">' +
      '<h3>About This Walk</h3>' +
      '<p>' + walk.description + '</p>' +
      '<h3>Points of Interest</h3>' +
      '<div class="poi-list">' + poisHtml + '</div>' +
      '<div class="walk-tip">' +
      '<div class="walk-tip-icon">&#128161;</div>' +
      '<p><strong>Tip:</strong> ' + walk.tips + '</p>' +
      '</div>' +
      '</div>' +
      '</div>';

    // Navigate to detail page
    pageHistory.push(currentPage);
    currentPage = 'walk-detail';

    document.querySelectorAll('.page').forEach(function (p) {
      p.classList.remove('active');
    });
    document.getElementById('page-walk-detail').classList.add('active');

    headerTitle.textContent = walk.title;
    btnBack.classList.remove('hidden');

    // Keep walks nav active
    navItems.forEach(function (item) {
      item.classList.toggle('active', item.getAttribute('data-page') === 'walks');
    });

    pageContainer.scrollTo(0, 0);
    window.scrollTo(0, 0);
  }

  // ===== Go Back =====
  function goBack() {
    if (pageHistory.length > 0) {
      var prevPage = pageHistory.pop();
      navigateTo(prevPage, pageHistory.length === 0);
    } else {
      navigateTo('home', true);
    }
  }

  // ===== Service Worker Registration =====
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function () {
      navigator.serviceWorker.register('sw.js').catch(function () {
        // Service worker registration failed - app still works
      });
    });
  }

  // ===== Start =====
  document.addEventListener('DOMContentLoaded', init);
})();
