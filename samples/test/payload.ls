class CustosomeNode : gfx::objects::ObjectGfxNode
{
  gfx::objects::SuperObjectGfxNode@ self;
  const CustosomeLogic@ object;

  gfx::effects::WorkingEffect effect;
  
  gfx::Sprite@ sprite;
  float timer;

  void setSelf(gfx::objects::SuperObjectGfxNode@ self)
  {
    @this.self = self;
    @this.object = cast<CustosomeLogic>(self.object().scriptObject());
  }

  void generate() 
  {          
    self.generateBuildingBase();          
    @sprite = self.createSprite(417, 304, 48, 96, 0, 40);

    effect.setTarget(sprite);
  }

  void update(float dt)
  {
    effect.update(object.isWorking(), dt);
    //object.test();
    //timer += dt * 5.0f;
    //sprite.rotate(timer);
  }
};

class CustosomeLogic : objects::Object
{
  objects::SuperObject@ self;

  float timer;
  int count;

  CustosomeLogic()
  {
    timer = 0.0f;
    count = 0;
  }

  void setSelf(objects::SuperObject@ self)
  {
    @this.self = self;
  }

  bool isWorking() const
  {
    return timer > 0.0f;
  }

  const data::ItemArchetype@ retrieveItem()
  {
    if (count == 3)
    {
      count = 0;
      return data.item("cytostome2x");
    }

    return null;
  }

  bool depositItem(const data::ItemArchetype@ item, Direction dir)
  {
    if (timer == 0.0f && count < 3)
    {
      timer = 5.0f;
      return true;
    }
    else
      return false;
  }

  void update(float dt)
  {
    if (timer > 0.0f)
    {
      timer -= dt;

      if (timer < 0.0f)
      {
        ++count;
        timer = 0.0f;
      }
    }
  }

  void test() const
  {
    system::log("foobar");
  }
  
}

class MonkeyMod : Mod
{
  void onLoad()
  {
    //array<Rect>@ batch = gfx::assets::generateRectBatch(ipoint(0,0), 24, 20, 1, 8, 32, 0);
    //gfx::assets::registerGraphics("ingots.png", "ingots", batch);
  }

  void onGenerateMap()
  {
    array<item::Stack> content = {
      item::Stack(data.item("microtubule"), 1000),
      item::Stack(data.item("picker"), 1000),
    };
    
    //logic.placeResourceHeap(ipoint(0, 0), content);
    //logic.decorateChunk(ipoint(0,0), data.zone("extracellular_matrix"));
    //logic.decorateChunk(ipoint(1,0), data.zone("cytosol"));

  }

  void onDataLoaded()
  {
    data::ItemArchetype@ custosome = data.registerItem("custosome", data.itemCategory("molecule_synthesis"));
    data::ObjectArchetype@ custosomeObject = data.registerObject("custosome", custosome, object::Size(3, 3, 3));

    data.asset("item_custosome").replace(Rect(32, 32, 20, 28));

    data.registerString("item_name_custosome", "Custosome");
    gfx::registerObjectRenderer("custosome", "CustosomeNode");

    objects::registerObjectBuilder("custosome", "CustosomeLogic");

    Slice<data::RecipeStep> steps = data.recipe("tubulin_red").steps();
    Slice<item::Stack> input = steps[0].input();
    input[0] = item::Stack(data.item("tubulin_green"), 3);

    return;
    
    /*data.asset("item_aminoacid_red").replace(data.asset("ingots").rect(0));
    data.asset("item_aminoacid_green").replace(data.asset("ingots").rect(1));
    data.asset("item_aminoacid_yellow").replace(data.asset("ingots").rect(2));
    data.asset("item_aminoacid_blue").replace(data.asset("ingots").rect(3));*/
    
    array<ipoint> items = {
      ipoint(54, 26),
      ipoint(56, 26),
      ipoint(58, 26),
      ipoint(60, 26),
      ipoint(62, 26)
    };
   
    array<ipoint> bases = {
      ipoint(0, 78),
      ipoint(109, 0),
      ipoint(109, 8),
      ipoint(109, 16),
      ipoint(109, 24)
    };

    uint variant = game.seed() % bases.size();
    int x = bases[variant].x(), y = bases[variant].y();

    array<Rect>@ newWall = gfx::assets::generateTileBatch(ipoint(x, y), 1, 1, 2, 4);
    newWall = gfx::assets::remapWallStyle8toEdgeMap16(newWall, false);

    data.asset("zone_cytosol_wall_front_inner").replaceBatch(0, newWall);
    data.asset("zone_cytosol_wall_front").replaceBatch(0, newWall);

    array<Rect>@ newSurface = gfx::assets::generateTileBatch(ipoint(x + 4, y), 1, 1, 3, 3);
    newSurface = gfx::assets::remapSurface9toEdgeMap16(newSurface);
    data.asset("zone_cytosol_surface").replaceBatch(0, newSurface);

    array<Rect> newSurfaceFull = gfx::assets::generateTileBatch(ipoint(x + 7, y + 1), 1, 1, 2, 8);
    data.asset("zone_cytosol_surface").replaceBatch(1, newSurfaceFull);

    array<Rect> newSurfaceBedrock = gfx::assets::generateTileBatch(ipoint(x + 4, y + 3), 1, 1, 2, 4);
    newSurfaceBedrock = gfx::assets::remapWallStyle8toEdgeMap16(newSurfaceBedrock, true);
    data.asset("zone_cytosol_surface").replaceBatch(2, newSurfaceBedrock);

    array<Rect> newWallTop = gfx::assets::generateTileBatch(ipoint(x, y + 2), 1, 1, 4, 4);
    newWallTop = gfx::assets::remapSurfaceToEdgeMap(newWallTop);

    data.asset("zone_cytosol_wall_top").replaceBatch(0, newWallTop);

    array<Rect> newOverlay = gfx::assets::generateTileBatch(ipoint(x + 15, y), 1, 1, 5, 4);
    newOverlay = gfx::assets::remapSurfaceToEdgeMap(newOverlay);

    data.asset("zone_cytosol_overlay").replaceBatch(1, newOverlay);

    array<Rect> newOverlayFull = gfx::assets::generateTileBatch(ipoint(x + 10, y + 4), 1, 1, 1, 3);
    data.asset("zone_cytosol_overlay").replaceBatch(0, newOverlayFull);
    
    data.asset("zone_cytosol_props").replaceBatch(0, gfx::assets::generateTileBatch(ipoint(x + 4, y + 5), 1, 2, 1, 5));
    data.asset("zone_cytosol_props").replaceBatch(1, gfx::assets::generateTileBatch(ipoint(x + 4, y + 7), 1, 1, 1, 5));

    data.asset("item_cell_membrane").replace(Rect(items[variant].x() * 16, items[variant].y() * 16, 20, 25));

    //gfx::registerObjectRenderer("ribosome", "MyRibosomeNode");

    //system::log(data.recipe("microtubule").steps()[0].input()[0].type().identifier());

    return;

    // remove nad/nadh from Glycolysis
    {
      data::Recipe@ recipe = data.recipe("glycolysis");
      recipe.removeItem(data.item("nad"));
      recipe.removeItem(data.item("nadh"));
    }

    // remove fermentation which is not needed anymore at this point
    {
      data.removeEvolutionStep("alcoholic_fermentation");
    }

    // remoce nad/nadh from Pyruvate Dehydrogenase
    {
      data::Recipe@ recipe = data.recipe("pyruvate_dehydrogenase");
      recipe.removeItem(data.item("nad"));
      recipe.removeItem(data.item("nadh"));
    }

    data.setAttribute("object_stockpile2x_capacity", 100);
    //data.setAttribute("object_cytostome1x", "oxidationUses", 1000);


    data::Recipe@ recipe = data.recipe("ribosome");

    array<item::Stack> newInput = {
      item::Stack(data.item("tubulin_green"), 10),
      item::Stack(data.item("tubulin_red"), 8)
    };

    data.recipe("cytostome1x").steps()[0].input() = newInput;

    data.evolutionStep("primitive_logistics").removeRecipe(data.recipe("microtubule_primitive"));
    data.evolutionStep("primitive_logistics").addRecipe(data.recipe("microtubule"));

    data.recipe("cytostome1x").steps()[0].input().add(item::Stack(data.item("subunit_blue"), 1));
    //recipe.steps()[0].input()[0] = item::Stack(data::item("evolver_subunit"), 3);
    
  }

  void onDataFinalization()
  {

  }
}